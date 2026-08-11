# --------------- Locals -----------------

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# --------------- VPC module -----------------

module "vpc" {
  source = "../../modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
  az_count     = var.az_count
  common_tags  = local.common_tags
}

# --------------- IAM module -----------------
# IAM before EC2 because EC2 needs instance profile and role from IAM

module "iam" {
  source = "../../modules/iam"

  project_name = var.project_name
  environment  = var.environment
  bucket_arn   = module.s3.bucket_arn
  common_tags  = local.common_tags
}

# --------------- S3 module -----------------

module "s3" {
  source = "../../modules/s3"

  project_name       = var.project_name
  environment        = var.environment
  versioning_enabled = var.versioning_enabled
  lifecycle_days     = var.lifecycle_days
  common_tags        = local.common_tags
}

# --------------- EC2 module -----------------

module "ec2" {
  source = "../../modules/ec2"

  project_name          = var.project_name
  environment           = var.environment
  instance_type         = var.instance_type
  min_size              = var.min_size
  max_size              = var.max_size
  desired_capacity      = var.desired_capacity
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  private_subnet_ids    = module.vpc.private_subnet_ids
  instance_profile_name = module.iam.instance_profile_name
  common_tags           = local.common_tags

  depends_on = [module.vpc, module.iam]
}

# --------------- RDS module -----------------

module "rds" {
  source = "../../modules/rds"

  project_name            = var.project_name
  environment             = var.environment
  db_instance_class       = var.db_instance_class
  allocated_storage       = var.allocated_storage
  multi_az                = var.multi_az
  ec2_security_group_id   = module.ec2.ec2_security_group_id
  backup_retention_period = var.backup_retention_period
  db_name                 = var.db_name
  db_username             = var.db_username
  db_password             = var.db_password
  deletion_protection     = var.deletion_protection
  skip_final_snapshot     = var.skip_final_snapshot
  vpc_id                  = module.vpc.vpc_id
  private_subnet_ids      = module.vpc.private_subnet_ids
  common_tags             = local.common_tags

  depends_on = [module.vpc, module.ec2]
}

# --------------- CloudWatch module -----------------

module "cloudwatch" {
  source = "../../modules/cloudwatch"

  project_name           = var.project_name
  environment            = var.environment
  db_instance_identifier = module.rds.db_instance_identifier
  asg_name               = module.ec2.asg_name
  alert_email            = var.alert_email
  log_retention_days     = var.log_retention_days
  cpu_threshold          = var.cpu_threshold
  common_tags            = local.common_tags

  depends_on = [module.ec2, module.rds]
}