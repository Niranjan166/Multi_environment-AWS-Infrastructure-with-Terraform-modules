project_name = "nkapp"
environment  = "staging"
aws_region   = "us-east-1"

# ---------------- VPC ------------------
vpc_cidr = "10.1.0.0/16"
az_count = 2

# ---------------- EC2 ------------------
instance_type    = "t2.micro"
min_size         = 2
max_size         = 4
desired_capacity = 2

# ---------------- RDS ------------------
db_instance_class       = "db.t3.small"
allocated_storage       = 20
multi_az                = false
backup_retention_period = 1
db_name                 = "nkappdb"
db_username             = "admin"
deletion_protection     = false
skip_final_snapshot     = true

# ---------------- S3 ------------------
versioning_enabled = true
lifecycle_days     = 60

# ---------------- CloudWatch ------------------
log_retention_days = 14
cpu_threshold      = 70