variable "project_name" {
  description = "Name of the project"
  type = string
}

variable "environment" {
  description = "Environment name"
  type = string
}

variable "aws_region" {
  description = "AWS region to deploy resources"
  type = string
  default = "us-east-1"
}

# ---------------- VPC ------------------

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type = string
}

variable "az_count" {
  description = "Number of availability zones"
  type = number
}

# ---------------- EC2 ------------------

variable "instance_type" {
  description = "Type of EC2 instance to launch"
  type = string
}

variable "min_size" {
  description = "Minimum instances in ASG"
  type = number
}

variable "max_size" {
  description = "Maximum instances in ASG"
  type = number
}

variable "desired_capacity" {
  description = "Desired instances in ASG"
  type = number
}

# ---------------- RDS ------------------

variable "db_instance_class" {
  description = "Instance class for RDS"
  type = string
}

variable "allocated_storage" {
  description = "Allocated storage for RDS in GB"
  type = number
}

variable "multi_az" {
  description = "Whether to create a multi-AZ RDS instance"
  type = bool
}

variable "backup_retention_period" {
  description = "Backup retention days for RDS"
  type = number
}  

variable "db_name" {
  description = "Database name for RDS"
  type = string
}

variable "db_username" {
  description = "Username for RDS"
  type = string
}

variable "db_password" {
  description = "Password for RDS"
  type = string
  sensitive = true
}

variable "deletion_protection" {
  description = "Enable RDS deletion protection"
  type = bool
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot on RDS deletion"
  type = bool
}

# ---------------- S3 ------------------

variable "versioning_enabled" {
    description = "Enable versioning for the S3 bucket"
    type        = bool
    # dev - false/ staging - true/ prod - true}
}

variable "lifecycle_days" {
    description = "Number of days after which noncurrent versions will be deleted"
    type        = number
    # dev - 30/ staging - 60/ prod - 90
}

# ---------------- CloudWatch ------------------

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "cpu_threshold" {
  description = "CPU utilization threshold for CloudWatch alarm"
  type        = number
  default     = 60  
}

variable "alert_email" {
  description = "email address for cloudwatch alert notification"
  type = string
}