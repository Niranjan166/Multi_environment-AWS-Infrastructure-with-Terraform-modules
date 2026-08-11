output "instance_profile_name" {
  description = "IAM Instance Profile name"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "instance_profile_arn" {
  description = "ARN of IAM instance profile"
  value       = aws_iam_instance_profile.ec2_profile.arn
}

output "role_name" {
  description = "IAM Role name"
  value       = aws_iam_role.ec2_role.name
}

output "role_arn" {
  description = "IAM Role ARN"
  value       = aws_iam_role.ec2_role.arn
}