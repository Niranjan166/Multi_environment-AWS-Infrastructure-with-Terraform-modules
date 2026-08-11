terraform {
  backend "s3" {
    bucket         = "nkapp-dev-tfstate"
    key            = "dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "nkapp-dev-tflock"
  }
}