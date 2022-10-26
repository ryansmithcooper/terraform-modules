#########################
### LOCAL DEFINITIONS ###
#########################

locals {
  functional_groups = {
    "administrators"     = { group_name = "Administrators", group_desc = "" }
    "service"            = { group_name = "Service Accounts", group_desc = "" }
    "everyone"           = { group_name = "Everyone", group_desc = "All users in your organization" }
    "exceptions"         = { group_name = "Exceptions", group_desc = "For exceptional cases that require Okta MFA" }
  }

  department_groups = {
    "developers"       = { group_name = "Developers", group_desc = "" }
    "ops"              = { group_name = "Ops", group_desc = "" }
    "qa"               = { group_name = "QA", group_desc = "" }
    "security"         = { group_name = "Security", group_desc = "" }
    "it"               = { group_name = "IT", group_desc = "" }
  }

  application_groups = {
    "google"              = { group_name = "GCP", group_desc = "" }
  }

}

#########################
### FUNCTIONAL GROUPS ###
#########################

resource "okta_group" "functional" {
  for_each    = local.functional_groups
  name        = each.value.group_name
  description = each.value.group_desc
}

resource "okta_group_role" "administrators" {
  group_id  = okta_group.functional["administrators"].id
  role_type = ""
}

#########################
### DEPARTMENT GROUPS ###
#########################

resource "okta_group" "department" {
  for_each    = local.department_groups
  name        = each.value.group_name
  description = each.value.group_desc
}

###########################
#### APPLICATION GROUPS ###
###########################

resource "okta_group" "application" {
  for_each    = local.application_groups
  name        = each.value.group_name
  description = each.value.group_desc
}