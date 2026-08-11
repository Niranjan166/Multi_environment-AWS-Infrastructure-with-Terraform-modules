
provider "aws" {
  region = "us-east-1"
}

# s3 buckets (one per environment)

resource "aws_s3_bucket" "terraform_state" {
  for_each = toset([      #for_each - 3 iterations and toset coverts the list into set to avoid duplicates.

    "dev",
    "staging",
    "prod"
  ])
  bucket = "nkapp-${each.key}-tfstate"

  lifecycle {
    prevent_destroy = true
  }
  
  tags = {
    Name        = "nkapp-${each.key}-tfstate"
    Environment = each.key
    Project     = "nkapp"
    ManagedBy   = "Terraform"
  }
  
}

# enable versioning for the s3 buckets

resource "aws_s3_bucket_versioning" "terraform_state" {
  for_each = aws_s3_bucket.terraform_state
  bucket   = each.value.id

  versioning_configuration {
    status = "Enabled"
  }
}

# enable server-side encryption for the s3 buckets

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  for_each = aws_s3_bucket.terraform_state
  bucket   = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# block public access for the s3 buckets

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  for_each = aws_s3_bucket.terraform_state
  bucket   = each.value.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# create a dynamodb table for state locking (one per environment)

resource "aws_dynamodb_table" "terraform_lock" {
  for_each = toset([
    "dev",
    "staging",
    "prod"
  ])
  name = "nkapp-${each.key}-tflock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = "nkapp-${each.key}-tflock"
    Environment = each.key
    Project     = "nkapp"
    ManagedBy   = "Terraform"
  }
}

# output the s3 bucket names and dynamodb table names

output "state_bucket_names" {
  value = { for env, bucket in aws_s3_bucket.terraform_state : env => bucket.id }

  description = "The names of the S3 buckets used for Terraform state storage."
}

output "dynamodb_table_names" {
  value = { for env, table in aws_dynamodb_table.terraform_lock : env => table.name }

  description = "The names of the DynamoDB tables used for Terraform state locking."
}