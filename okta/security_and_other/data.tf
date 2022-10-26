#####################
### REMOTE STATES ###
#####################

data "terraform_remote_state" "groups" {
  backend = "s3"
  config = {
    bucket = "example-bucket"
    key    = "okta/groups/terraform.tfstate"
    region = "us-east-1"
  }
}