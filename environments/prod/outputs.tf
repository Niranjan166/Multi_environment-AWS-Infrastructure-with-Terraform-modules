output "alb_dns_name" {
  description = "ALB DNS name - open this in browser"
  value = module.ec2.alb_dns_name
}

output "rds_endpoint" {
  description = "RDS database endpoint"
  value = module.rds.db_endpoint
}

output "s3_bucket_id" {
  description = "S3 bucket ID"
  value = module.s3.bucket_id
}

output "vpc_id" {
  description = "VPC ID"
  value = module.vpc.vpc_id
}