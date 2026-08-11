terraform {
  backend "s3" {
    bucket = "nkapp-staging-tfstate"
    key = "staging/terraform"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "nkapp-staging-tflock"
  }
}