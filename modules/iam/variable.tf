variable "project_name" {
  description = "Name of project"
  type = string
}

variable "environment" {
  description = "Environment Name"
  type = string
}

variable "bucket_arn" {
    description = "ARN of s3 bucket ec2 needs access to"
    type = string
}

variable "common_tags" {
    description = "Common tags to apply to all resources"
    type = map(string)
    default = {}
}
