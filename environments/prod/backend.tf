terraform {
  backend "s3" {
    bucket = "nkapp-prod-tfstate"
    key = "prod/terraform"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "nkapp-prod-tflock"
  }
}