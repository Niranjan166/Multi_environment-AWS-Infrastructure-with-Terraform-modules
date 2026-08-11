variable "project_name" {
    description = "The name of the project"
    type = string
}

variable "environment" {
    description = "The environment (e.g., dev, staging, prod)"
    type = string
}  

variable "private_subnet_ids" {
    description = "List of private subnet IDs for EC2"
    type = list(string)
}

variable "vpc_id" {
    description = "The ID of the VPC where resources will be created"
    type = string
}

variable "ec2_security_group_id" {
    description = "The ID of the EC2 security group"
    type = string  
}

variable "db_instance_class" {
    description = "The instance class for the RDS instance"
    type = string 
}

variable "db_name" {
    description = "The name of the database to create"
    type = string  
}

variable "db_username" {
    description = "The username for the database"
    type = string  
}

variable "db_password" {
    description = "The password for the database"
    type = string
    sensitive = true
}

variable "allocated_storage" {
    description = "The allocated storage in gigabytes"
    type = number
    default = 20
}

variable "multi_az" {
    description = "Whether to create a Multi-AZ RDS instance"
    type = bool
    #default = false (without default, the user must explicitly provide a value before deployment)
}

variable "backup_retention_period" {
    description = "The number of days to retain backups for"
    type = number 
    #default = 7 
}

variable "deletion_protection" {
    description = "Whether to enable deletion protection for the RDS instance"
    type = bool
    #default = false
}

variable "skip_final_snapshot" {
    description = "Whether to skip the final snapshot when deleting the RDS instance"
    type = bool
    #default = false  
}

variable "common_tags" {
    description = "Common tags to apply to all resources"
    type = map(string)
    default = {}
}