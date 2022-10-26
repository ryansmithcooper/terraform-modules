#########################
### LOCAL DEFINITIONS ###
#########################

locals {
  google_workspace_groups = {
    "google" = { app_id = okta_app_saml.google_workspace.id, group_id = data.terraform_remote_state.groups.outputs.application_group["google"] }
  }
  google_cloud_groups = {
    "google" = { app_id = okta_app_bookmark.google_cloud.id, group_id = data.terraform_remote_state.groups.outputs.application_group["google"] }
  }
}

####################
### APPLICATIONS ###
####################

#########################
### GLOOGLE WORKSPACE ###
#########################

resource "okta_app_saml" "google_workspace" {
  accessibility_self_service = false
  app_links_json = jsonencode(
    {
      accounts = true
      calendar = false
      drive    = false
      keep     = false
      mail     = false
      sites    = false
    }
  )
  app_settings_json = jsonencode(
    {
      afwOnly = false
      domain  = "example.mygbiz.com"
    }
  )
  assertion_signed    = false
  auto_submit_toolbar = false
  features = [
    "GROUP_PUSH",
    "IMPORT_NEW_USERS",
    "IMPORT_USER_SCHEMA",
    "PUSH_NEW_USERS",
    "PUSH_PASSWORD_UPDATES",
    "PUSH_PROFILE_UPDATES",
    "PUSH_USER_DEACTIVATION",
    "REACTIVATE_USERS",
  ]
  hide_ios                       = true
  hide_web                       = true
  honor_force_authn              = false
  label                          = "Google Workspace"
  preconfigured_app              = "google"
  response_signed                = false
  saml_version                   = "2.0"
  status                         = "ACTIVE"
  user_name_template             = "String.toLowerCase(user.firstName+\".\"+user.lastName+\"@example.com\")"
  user_name_template_push_status = "DONT_PUSH"
  user_name_template_type        = "CUSTOM"
  skip_groups                    = false
  skip_users                     = true

  lifecycle {
    ignore_changes = [groups]
  }
}

resource "okta_app_group_assignment" "google_workspace" {
  for_each = local.google_workspace_groups
  app_id   = each.value.app_id
  group_id = each.value.group_id
}

#####################
### GLOOGLE CLOUD ###
#####################

resource "okta_app_bookmark" "google_cloud" {
  accessibility_self_service = false
  app_links_json             = jsonencode({ login = true })
  auto_submit_toolbar        = false
  hide_ios                   = false
  hide_web                   = false
  label                      = "Google Cloud Platform"
  request_integration        = false
  status                     = "ACTIVE"
  url                        = "example.com"
  skip_groups                = false
  skip_users                 = true

  lifecycle {
    ignore_changes = [groups]
  }
}


resource "okta_app_group_assignment" "google_cloud" {
  for_each = local.google_cloud_groups
  app_id   = each.value.app_id
  group_id = each.value.group_id
}