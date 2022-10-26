terraform {
  backend "s3" {
    bucket         = "example-bucket"
    key            = "okta/application/jenkins/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "example-lock-table"
    encrypt        = true
  }
}