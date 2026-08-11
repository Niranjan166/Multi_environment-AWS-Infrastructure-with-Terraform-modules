variable "project_name" {
  description = "Name of the project"
  type = string
}

variable "environment" {
  description = "Environment name"
  type = string
}

variable "common_tags" {
  description = "Common tags applied to all resources"
  type = map(string)
  default = {}
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "cpu_threshold" {
  description = "CPU utilization threshold for CloudWatch alarm"
  type        = number
  default     = 70  
}

variable "alert_email" {
  description = "email address for cloudwatch alert notification"
  type = string
}

variable "asg_name" {
  description = "Name of the Auto Scaling Group"
  type = string
}

variable "db_instance_identifier" {
  description = "Identifier of the RDS instance"
  type = string
}