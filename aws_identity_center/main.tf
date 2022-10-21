# omitted variable definitions & provider definitions

###############
### MODULES ###
###############

module "tags" {
  source = "./path/to/module/"

  tag_application   = var.tag_application
  tag_environment   = var.tag_environment
  tag_name          = var.tag_name
  tag_owner         = var.tag_owner
  tag_service       = var.tag_service
  tag_version       = var.tag_version
  tag_map_server_id = var.tag_map_server_id
}

#########################
### LOCAL DEFINITIONS ###
#########################

locals {
  idc_groups = {
    "ops"    = { path = "DisplayName", value = "Ops" }
    "developers" = { path = "DisplayName", value = "Developers" }
    "qa"         = { path = "DisplayName", value = "QA" }
    "security"   = { path = "DisplayName", value = "Security" }
    "it"         = { path = "DisplayName", value = "IT" }
  }

  permission_sets = {
    "administrator"        = { name = "Administrator", desc = "Administrator access", duration = "PT1H" }
    "read_only"            = { name = "ReadOnly", desc = "Read-only permissions", duration = "PT1H" }
    "security_auditor"     = { name = "SecurityAuditor", desc = "Security auditor permissions.", duration = "PT1H" }
    "operations"           = { name = "Operations", desc = "Operations permissions", duration = "PT4H" }
    "developer"            = { name = "Developer", desc = "Developer permissions", duration = "PT4H" }
  }

  managed_policy_attachments = {
    "administrator"               = { policy_arn = var.admin_access_policy_arn, permission_arn = aws_ssoadmin_permission_set.set["administrator"].arn }
    "read_only"                   = { policy_arn = var.read_only_policy_arn, permission_arn = aws_ssoadmin_permission_set.set["read_only"].arn }
    "security_auditor"            = { policy_arn = var.security_auditor_policy_arn, permission_arn = aws_ssoadmin_permission_set.set["security_auditor"].arn }
    "operations"                  = { policy_arn = var.power_user_policy_arn, permission_arn = aws_ssoadmin_permission_set.set["operations"].arn }
    "developer"                   = { policy_arn = var.power_user_policy_arn, permission_arn = aws_ssoadmin_permission_set.set["developer"].arn }
    "developer_iam_read"          = { policy_arn = var.iam_read_only_policy_arn, permission_arn = aws_ssoadmin_permission_set.set["developer"].arn }
  }

  inline_policy_attachments = {
    "trusted_advisor_full" = { inline_policy = data.aws_iam_policy_document.trusted_advisor_all.json, permission_set_arn = aws_ssoadmin_permission_set.set["org_auditor"].arn }
  }

  account_assignments = {

    "security_audtor_test_1" = {
      perm_set     = aws_ssoadmin_permission_set.set["security_auditor"].arn,
      principal_id = data.aws_identitystore_group.group["security"].id,
      target_id    = data.terraform_remote_state.organization.outputs.account_ids["test_1"]
    }
    "ops_admin_test_2" = {
      perm_set     = aws_ssoadmin_permission_set.set["administrator"].arn,
      principal_id = data.aws_identitystore_group.group["ops"].id,
      target_id    = data.terraform_remote_state.organization.outputs.account_ids["test_2"]
    }
    "it_readonly_test_1" = {
      perm_set     = aws_ssoadmin_permission_set.set["read_only"].arn,
      principal_id = data.aws_identitystore_group.group["it"].id,
      target_id    = data.terraform_remote_state.organization.outputs.account_ids["test_1"]
    }
    "security_admin_test_2" = {
      perm_set     = aws_ssoadmin_permission_set.set["administrator"].arn,
      principal_id = data.aws_identitystore_group.group["security"].id,
      target_id    = data.terraform_remote_state.organization.outputs.account_ids["test_2"]
    }
}
}

#########################
### REMOTE STATE DATA ###
#########################

data "terraform_remote_state" "organization" {
  backend = "s3"
  config = {
    bucket = var.state_bucket
    key    = var.state_bucket_key
    region = var.aws_region
  }
}

#########################
### AWS RESOURCE DATA ###
#########################

data "aws_ssoadmin_instances" "this" {

}

data "aws_identitystore_group" "this" {
  for_each          = local.idc_groups
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  filter {
    attribute_path  = each.value.path
    attribute_value = each.value.value
  }
}

###########
### IAM ###
###########

data "aws_iam_policy_document" "trusted_advisor_all" {
  policy_id = "TrustedAdvisorFullAccess"

  statement {
    actions = [
      "trustedadvisor:*"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

###########################
### IAM IDENTITY CENTER ###
###########################

resource "aws_ssoadmin_permission_set" "this" {
  for_each         = local.permission_sets
  instance_arn     = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  name             = each.value.name
  description      = each.value.desc
  session_duration = each.value.duration
}

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each           = local.managed_policy_attachments
  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  managed_policy_arn = each.value.policy_arn
  permission_set_arn = each.value.permission_arn
}

resource "aws_ssoadmin_account_assignment" "this" {
  for_each           = local.account_assignments
  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_set_arn = each.value.perm_set
  principal_id       = each.value.principal_id
  target_id          = each.value.target_id
  principal_type     = "GROUP"
  target_type        = "AWS_ACCOUNT"
}

resource "aws_ssoadmin_permission_set_inline_policy" "this" {
  for_each           = local.inline_policy_attachments
  instance_arn       = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  inline_policy      = each.value.inline_policy
  permission_set_arn = each.value.permission_set_arn
}