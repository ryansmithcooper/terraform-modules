terraform {
  backend "s3" {
    bucket         = "example-bucket"
    key            = "okta/application/google/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "example-lock-table"
    encrypt        = true
  }
}