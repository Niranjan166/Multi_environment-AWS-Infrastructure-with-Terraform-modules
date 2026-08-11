variable "project_name" {
  description = "Name of the project"
  type = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type = string
}

variable "vpc_id" {
  description = "The ID of the VPC where resources will be created"
  type = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for EC2"
  type = list(string)
}

variable "instance_type" {
  description = "The type of EC2 instance to launch"
  type = string
}

variable "min_size" {
  description = "The minimum number of EC2 instances in ASG"
  type = number
}

variable "max_size" {
  description = "The maximum number of EC2 instances in ASG"
  type = number
}

variable "desired_capacity" {
  description = "The desired number of EC2 instances in ASG"
  type = number
} 

variable "instance_profile_name" {
  description = "The name of the IAM instance profile for EC2 instances"
  type = string
} 

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type = map(string)
  default = {}
}