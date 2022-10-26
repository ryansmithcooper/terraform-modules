#########################
### LOCAL DEFINITIONS ###
#########################

locals {
  jenkins_aws_uat_groups = {
    "ops"        = { app_id = okta_app_saml.jenkins_aws_uat.id, group_id = data.terraform_remote_state.groups.outputs.department_group["ops"] }
    "qa"         = { app_id = okta_app_saml.jenkins_aws_uat.id, group_id = data.terraform_remote_state.groups.outputs.department_group["qa"] }
    "security"   = { app_id = okta_app_saml.jenkins_aws_uat.id, group_id = data.terraform_remote_state.groups.outputs.department_group["security"] }
    "developers" = { app_id = okta_app_saml.jenkins_aws_uat.id, group_id = data.terraform_remote_state.groups.outputs.department_group["developers"] }
  }
  jenkins_aws_prod_groups = {
    "ops"                = { app_id = okta_app_saml.jenkins_aws_prod.id, group_id = data.terraform_remote_state.groups.outputs.department_group["ops"] }
    "developers"         = { app_id = okta_app_saml.jenkins_aws_prod.id, group_id = data.terraform_remote_state.groups.outputs.department_group["developers"] }
    "qa"                 = { app_id = okta_app_saml.jenkins_aws_prod.id, group_id = data.terraform_remote_state.groups.outputs.department_group["qa"] }
    "security"           = { app_id = okta_app_saml.jenkins_aws_prod.id, group_id = data.terraform_remote_state.groups.outputs.department_group["security"] }
  }
}

####################
### APPLICATIONS ###
####################

#######################
### JENKINS AWS UAT ###
#######################

resource "okta_app_saml" "jenkins_aws_uat" {
  accessibility_self_service = false
  app_links_json             = jsonencode({ jenkins_link = true })
  app_settings_json          = jsonencode({ baseUrl = "https://jenkins-uat.example.com" })
  assertion_signed           = false
  auto_submit_toolbar        = false
  features                   = []
  hide_ios                   = true
  hide_web                   = true
  implicit_assignment        = false
  label                      = "Jenkins UAT (AWS)"
  preconfigured_app          = "jenkins"
  response_signed            = false
  saml_version               = "2.0"
  status                     = "ACTIVE"
  user_name_template         = "$${source.login}"

  attribute_statements {
    name      = "userName"
    namespace = "urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified"
    type      = "EXPRESSION"
    values = [
      "user.login",
    ]
  }
  attribute_statements {
    filter_type  = "REGEX"
    filter_value = "Developers.*|Ops.*|QA.*|Security.*"
    name         = "Group"
    namespace    = "urn:oasis:names:tc:SAML:2.0:attrname-format:basic"
    type         = "GROUP"
    values       = []
  }
  skip_groups = false
  skip_users  = true

  lifecycle {
    ignore_changes = [groups]
  }
}

resource "okta_app_group_assignment" "jenkins_aws_uat" {
  for_each = local.jenkins_aws_uat_groups
  app_id   = each.value.app_id
  group_id = each.value.group_id
}

########################
### JENKINS AWS PROD ###
########################

resource "okta_app_saml" "jenkins_aws_prod" {
  accessibility_self_service = false
  app_links_json             = jsonencode({ jenkins_link = true })
  app_settings_json          = jsonencode({ baseUrl = "https://jenkins.example.com" })
  assertion_signed           = false
  auto_submit_toolbar        = false
  features                   = []
  hide_ios                   = false
  hide_web                   = false
  honor_force_authn          = false
  label                      = "Jenkins Production (AWS)"
  preconfigured_app          = "jenkins"
  response_signed            = false
  saml_version               = "2.0"
  status                     = "ACTIVE"
  user_name_template         = "$${source.login}"
  user_name_template_type    = "BUILT_IN"

  attribute_statements {
    name      = "userName"
    namespace = "urn:oasis:names:tc:SAML:2.0:attrname-format:unspecified"
    type      = "EXPRESSION"
    values    = ["user.login", ]
  }
  attribute_statements {
    filter_type  = "REGEX"
    filter_value = "Developers.*|Ops.*|QA.*|Security.*"
    name         = "Group"
    namespace    = "urn:oasis:names:tc:SAML:2.0:attrname-format:basic"
    type         = "GROUP"
    values       = []
  }
  skip_groups = false
  skip_users  = true

  lifecycle {
    ignore_changes = [groups]
  }
}

resource "okta_app_group_assignment" "jenkins_aws_prod" {
  for_each = local.jenkins_aws_prod_groups
  app_id   = each.value.app_id
  group_id = each.value.group_id
}
