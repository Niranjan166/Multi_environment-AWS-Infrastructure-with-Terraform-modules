variable "project_name" {
    description = "The name of the project"
    type        = string
}

variable "environment" {
    description = "The environment (e.g., dev, staging, prod)"
    type        = string
}

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

variable "common_tags" {
    description = "A map of common tags to apply to all resources"
    type        = map(string)
    default ={}  
}