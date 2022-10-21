terraform {
  backend "s3" {
    bucket         = "enl-terraform-org-master-state"
    key            = "iam-id-center/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "enl-terraform-org-master-state-us-east-1-common-lock"
    encrypt        = true
  }
}