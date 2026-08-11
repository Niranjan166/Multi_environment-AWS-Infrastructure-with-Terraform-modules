# IAM roles for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name               = "${var.project_name}-${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-ec2-role"
  })
}

# IAM policy for EC2 instances

resource "aws_iam_policy" "s3_access" {
  name        = "${var.project_name}-${var.environment}-ec2-instance-policy"
  description = "Allow EC2 to access application s3 bucket"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
            var.bucket_arn,
            "${var.bucket_arn}/*"
        ]
      }
    ]
  })  
}

/*# Cloudwatch logs policy

resource "aws_iam_policy" "cloudwatch_logs" {
  name     = "${var.project_name}-${var.environment}-cloudwatch-logs-policy"
  description = "Allow EC2 to write logs to CloudWatch"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# ssm policy

resource "aws_iam_policy" "ssm_access"{
    name        = "${var.project_name}-${var.environment}-ssm-access-policy"
    description = "Allow EC2 to access SSM"
    policy      = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Effect   = "Allow"
            Action   = [
            "ssm:UpdateInstanceInformation",
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel"
            ]
            Resource = "*"
        }
        ]
    })
} */

# Attach the policy to the EC2 role
resource "aws_iam_role_policy_attachment" "s3_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.s3_access.arn
  
}

/* resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
    role       = aws_iam_role.ec2_role.name
    policy_arn = aws_iam_policy.cloudwatch_logs.arn
} */

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

/* resource "aws_iam_role_policy_attachment" "ssm_access" {
    role       = aws_iam_role.ec2_role.name
    policy_arn = aws_iam_policy.ssm_access.arn
} */

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# instance profile

resource "aws_iam_instance_profile" "ec2_profile"{
    name = "${var.project_name}-${var.environment}-ec2_profile"
    role = aws_iam_role.ec2_role.name

    tags = merge(var.common_tags, {
        Name = "${var.project_name}-${var.environment}-ec2_profile"
    })
}