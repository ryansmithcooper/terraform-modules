###############
### BACKEND ###
###############

terraform {
  backend "s3" {
    bucket         = "example-bucket"
    key            = "okta/bookmarks/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "example-lock-table"
    encrypt        = true
  }
}