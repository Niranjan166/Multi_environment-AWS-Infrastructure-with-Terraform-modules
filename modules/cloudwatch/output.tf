output "log_group_name" {
    description = "CloudWatch Log Group name"
    value = aws_cloudwatch_log_group.ec2.name
}

output "log_group_arn" {
  description = "CloudWatch Log Group ARN"
  value       = aws_cloudwatch_log_group.ec2.arn
}

output "sns_topic_arn" {
  description = "SNS Topic ARN for CloudWatch alerts"
  value       = aws_sns_topic.alerts.arn
}

output "ec2_cpu_alarm_name" {
  description = "EC2 CPU Alarm name"
  value       = aws_cloudwatch_metric_alarm.cpu_high.alarm_name
}

output "ec2_status_check_alarm_name" {
  description = "EC2 Status Check Alarm name"
  value       = aws_cloudwatch_metric_alarm.ec2_status_check.alarm_name
}

output "rds_cpu_alarm_name" {
  description = "RDS CPU Alarm name"
  value       = aws_cloudwatch_metric_alarm.rds_cpu.alarm_name
}

output "application_error_alarm_name" {
  description = "Application Error Alarm name"
  value       = aws_cloudwatch_metric_alarm.application_errors.alarm_name
}