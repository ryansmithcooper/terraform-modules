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

#########################
### LOCAL DEFINITIONS ###
#########################

locals {
  functional_group_rules = {
    "exceptions" = {
      rule_name         = "userType-to-Exceptions",
      rule_status       = "ACTIVE",
      group_assignments = [data.terraform_remote_state.groups.outputs.functional_group["exceptions"]],
      expression_value  = "user.userType==\"Exception\""
    }
  }

  department_group_rules = {
    "orgcode_ops" = {
      rule_name         = "OrgCode-to-Ops",
      rule_status       = "ACTIVE",
      group_assignments = [data.terraform_remote_state.groups.outputs.department_group["ops"]],
      expression_value  = "user.orgCode==\"OPS\""
    }
    "orgcode_developers" = {
      rule_name         = "OrgCode-to-Developers",
      rule_status       = "ACTIVE",
      group_assignments = [data.terraform_remote_state.groups.outputs.department_group["developers"]],
      expression_value = join(" ", [
        "user.orgCode==\"DEV\"",
        "OR user.orgCode==\"DEV 1\""])
    }
    "orgcode_qa" = {
      rule_name         = "OrgCode-to-QA",
      rule_status       = "ACTIVE",
      group_assignments = [data.terraform_remote_state.groups.outputs.department_group["qa"]],
      expression_value = join(" ", [
        "user.orgCode==\"QA\"",
        "OR user.orgCode==\"QA 1\""])
    }
    "orgcode_security" = {
      rule_name         = "OrgCode-to-Security",
      rule_status       = "ACTIVE",
      group_assignments = [data.terraform_remote_state.groups.outputs.department_group["security"]],
      expression_value  = "user.orgCode==\"SEC\""
    }
    "orgcode_it" = {
      rule_name         = "OrgCode-to-IT",
      rule_status       = "ACTIVE",
      group_assignments = [data.terraform_remote_state.groups.outputs.department_group["it"]],
      expression_value  = "user.orgCode==\"IT\""
    }
  }
}

###############################
### FUNCTTIONAL GROUP RULES ###
###############################

resource "okta_group_rule" "functional_group_rule" {
  for_each          = local.functional_group_rules
  name              = each.value.rule_name
  status            = each.value.rule_status
  group_assignments = each.value.group_assignments
  expression_value  = each.value.expression_value

  lifecycle {
    create_before_destroy = true
  }

}

##############################
### DEPARTMENT GROUP RULES ###
##############################

resource "okta_group_rule" "department_group_rule" {
  for_each          = local.department_group_rules
  name              = each.value.rule_name
  status            = each.value.rule_status
  group_assignments = each.value.group_assignments
  expression_value  = each.value.expression_value

  lifecycle {
    create_before_destroy = true
  }

}