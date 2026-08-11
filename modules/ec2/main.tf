# Data source to fetch the latest Ubuntu AMI for the specified region

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"] 
    #ubuntu 20.04(focal) is getting old, we can use ubuntu 24.04 lts (noble) or 22.04 LTS (jammy)
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

# security group for the ALB (Application Load Balancer)

resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Security group for ALB"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP traffic from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

  ingress {
    description = "Allow HTTPS traffic from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  } 

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-alb-sg"
  })
}

# security group for the EC2 instance

resource "aws_security_group" "ec2" {
  name       = "${var.project_name}-${var.environment}-ec2-sg"
  description = "Security group for EC2 instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP traffic from ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "Allow HTTPS traffic from ALB"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-ec2-sg"
  })
}

# launch template for the EC2 instance

resource "aws_launch_template" "main" {
    name_prefix  = "${var.project_name}-${var.environment}-ec2-lt"
    image_id     = data.aws_ami.ubuntu.id
    instance_type = var.instance_type

    #network settings for instnacea created from this launch template
    network_interfaces {
        associate_public_ip_address = false
        security_groups = [aws_security_group.ec2.id]
    }

    #iam role for the EC2 instance
    #give EC2 permission to access AWS services (like S3, CloudWatch, etc)
    iam_instance_profile {
      name = var.instance_profile_name
    }

    #startup script for the EC2 instance (user data)
    #base64encode is used to encode the script in base64 format
    user_data = base64encode(<<-EOF
                #!/bin/bash
                apt-get update -y
                apt-get install -y apache2
                systemctl start apache2
                systemctl enable apache2  
                echo "<h1>Welcome to ${var.project_name} in ${var.environment} environment</h1>" > /var/www/html/index.html
                EOF
                )

    tag_specifications {
      resource_type = "instance"
      tags = merge(var.common_tags, {
        Name = "${var.project_name}-${var.environment}-ec2-instance"
      })
    }

    #lifecycle block to ensure that the launch template is created before 
    #any instances are destroyed (zero downtime)
    lifecycle {
      create_before_destroy = true
    }
}

#alb module to create an application load balancer

resource "aws_lb" "main" {
  name               = "${var.project_name}-${var.environment}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-alb"
  })
}

#target group for the ALB to route traffic to the EC2 instance

resource "aws_lb_target_group" "main" {
  name     = "${var.project_name}-${var.environment}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
 
  #health check -  ALB checks if ec2 is alive 
  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200" 
    #every http response has status code >> 200-OK, 201-created, 302-temporary redirect, 400-bad request, 404-not found, 500-server error
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-tg"
  })
}

#ALB listener to listen for incoming traffic on port 80 and forward it to the target group

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }  
}

#auto scaling group to manage the EC2 instances

resource "aws_autoscaling_group" "main" {
  name                      = "${var.project_name}-${var.environment}-asg"
  max_size                  = var.max_size
  min_size                  = var.min_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.private_subnet_ids
  target_group_arns         = [aws_lb_target_group.main.arn]
  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-ec2"
    propagate_at_launch = true
  }
  
  dynamic "tag" {
    for_each = var.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }  
}

#auto scaling policy to scale the EC2 instances based on CPU utilization

resource "aws_autoscaling_policy" "scale_up" {
  name                   = "${var.project_name}-${var.environment}-scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
}

resource "aws_autoscaling_policy" "scale_down" {
  name                   = "${var.project_name}-${var.environment}-scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.main.name
}