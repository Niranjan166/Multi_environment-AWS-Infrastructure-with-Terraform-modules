variable "project_name" {
    description = "The name of the project."
    type        = string
    default     = "nkapp"  
}

variable "environment" {
    description = "The environment for the infrastructure (dev, staging, prod)."
    type        = string
}

variable "vpc_cidr" {
    description = "The CIDR block for the VPC."
    type        = string
    #default     = "10.0.0.0/16"
}

variable "az_count" {
    description = "The number of availability zones to use."
    type        = number
    validation {
      condition = var.az_count>0 && var.az_count<=3
      error_message = "az_count must be between 1 and 3"
    }
}

variable "common_tags" {
    description = "Common tags to apply to all resources"
    type        = map(string)
    default     = {}
}