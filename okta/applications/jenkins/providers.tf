#########################
### REQUIRED VERSIONS ###
#########################

terraform {
  required_version = "=0.14.11"

  required_providers {
    okta = {
      source  = "okta/okta"
      version = "~> 3.20"
    }
  }
}

#################
### PROVIDERS ###
#################

# Okta Provider
# API key should be passed via an env variable (see: https://registry.terraform.io/providers/okta/okta/latest/docs)
provider "okta" {
  org_name = "example"
  base_url = "okta.com"
}