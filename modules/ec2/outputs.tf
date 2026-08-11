output "alb_dns_name" {
  description = "The DNS name of the ALB."
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "The ARN of the ALB."
  value       = aws_lb.main.arn
}

output "asg_name" {
  description = "The name of the ASG."
  value       = aws_autoscaling_group.main.name
}

output "ec2_security_group_id" {
  description = "security group id for ec2 instance"
  value       = aws_security_group.ec2.id
}

output "alb_security_group_id" {
  description = "security group id for alb"
  value       = aws_security_group.alb.id
}

output "target_group_arn" {
  description = "The ARN of the target group."
  value       = aws_lb_target_group.main.arn
}
