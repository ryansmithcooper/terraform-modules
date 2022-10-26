##########################
### IDENTITY PROVIDERS ###
##########################

resource "okta_idp_saml" "this" {
  account_link_action          = "AUTO"
  sso_url                      = "https://example.com"
  acs_type                     = "INSTANCE"
  deprovisioned_action         = "NONE"
  groups_action                = "NONE"
  groups_assignment            = []
  groups_filter                = []
  issuer                       = "https://example.com"
  kid                          = ""
  max_clock_skew               = 00000
  name                         = "Example"
  profile_master               = false
  provisioning_action          = "DISABLED"
  request_signature_algorithm  = ""
  request_signature_scope      = "REQUEST"
  response_signature_algorithm = ""
  response_signature_scope     = "ANY"
  subject_format               = []
  subject_match_attribute      = "ID"
  subject_match_type           = "CUSTOM_ATTRIBUTE"
  suspended_action             = ""
  username_template            = "example.testExample"
}

#####################
### ROUTING RULES ###
#####################

# All Okta orgs contain only one IdP Discovery Policy
data "okta_policy" "idp_discovery_policy" {
  name = "Idp Discovery Policy"
  type = "IDP_DISCOVERY"
}

resource "okta_policy_rule_idp_discovery" "this" {
  policy_id            = data.okta_policy.idp_discovery_policy.id
  name                 = "example"
  user_identifier_type = "IDENTIFIER"
  priority             = 2

  platform_include {
    os_type = "ANY"
    type    = "ANY"
  }

  user_identifier_patterns {
    match_type = "SUFFIX"
    value      = "example.com"
  }
}

resource "okta_policy_rule_idp_discovery" "exceptions" {
  policy_id                 = data.okta_policy.idp_discovery_policy.id
  name                      = "Exceptions"
  user_identifier_type      = "ATTRIBUTE"
  user_identifier_attribute = "userType"
  priority                  = 1

  platform_include {
    os_type = "ANY"
    type    = "ANY"
  }

  user_identifier_patterns {
    match_type = "EQUALS"
    value      = "Exception"
  }
}

#########################
### PASSWORD POLICIES ###
#########################

resource "okta_policy_password" "example" {
  name                           = "Example Policy"
  description                    = ""
  password_history_count         = 24
  groups_included                = [data.terraform_remote_state.groups.outputs.functional_group["everyone"]]
  priority                       = 4
  auth_provider                  = ""
  password_min_length            = 12
  password_min_lowercase         = 1
  password_min_uppercase         = 1
  password_min_number            = 1
  password_min_symbol            = 1
  password_exclude_username      = true
  password_exclude_first_name    = true
  password_exclude_last_name     = true
  password_dictionary_lookup     = true
  password_min_age_minutes       = 120
  password_max_lockout_attempts  = 10
  password_show_lockout_failures = true
  recovery_email_token           = 10080
}

resource "okta_policy_rule_password" "example" {
  policy_id          = okta_policy_password.example.id
  name               = "Default Rule"
  network_connection = "ANYWHERE"
  status             = "ACTIVE"
  password_change    = "DENY"
  password_reset     = "DENY"
}

########################
### SIGN-ON POLICIES ###
########################

resource "okta_policy_signon" "exceptions" {
  name            = "Exceptions Policy"
  status          = "ACTIVE"
  description     = "For use with exceptions that require Okta MFA"
  priority        = 3
  groups_included = [data.terraform_remote_state.groups.outputs.functional_group["exceptions"]]
}

resource "okta_policy_rule_signon" "exceptions" {
  access             = "ALLOW"
  mfa_required       = true
  authtype           = "ANY"
  name               = "Require MFA"
  network_connection = "ANYWHERE"
  policy_id          = okta_policy_signon.exceptions.id
  status             = "ACTIVE"
  risc_level         = "ANY"
  priority           = 1
  mfa_prompt         = "SESSION"
  mfa_lifetime       = 15
  session_lifetime   = 120
}

###################################
### MULTI-FACTOR AUTHENTICATION ###
###################################

resource "okta_factor" "okta_push" {
  provider_id = "okta_push"
}

resource "okta_factor" "okta_otp" {
  provider_id = "okta_otp"
}

resource "okta_factor" "google" {
  provider_id = "google_otp"
}

resource "okta_policy_mfa_default" "default" {
  google_otp = {
    consent_type = "NONE"
    enroll       = "NOT_ALLOWED"
  }
  is_oie = false
  okta_otp = {
    consent_type = "NONE"
    enroll       = "NOT_ALLOWED"
  }
  okta_password = {
    consent_type = "NONE"
    enroll       = "REQUIRED"
  }
  okta_push = {
    consent_type = "NONE"
    enroll       = "NOT_ALLOWED"
  }
}

resource "okta_policy_mfa" "exceptions" {
  name        = "Exceptions Policy"
  status      = "ACTIVE"
  description = "For use with excdeptional cases that require Okta MFA."
  is_oie      = false

  okta_push = {
    consent_type = "NONE"
    enroll       = "REQUIRED"
  }

  okta_otp = {
    consent_type = "NONE"
    enroll       = "REQUIRED"
  }

  google_otp = {
    consent_type = "NONE"
    enroll       = "NOT_ALLOWED"
  }

  groups_included = [data.terraform_remote_state.groups.outputs.functional_group["exceptions"]]
}

resource "okta_policy_rule_mfa" "exceptions" {
  policy_id = okta_policy_mfa.exceptions.id
  name      = "Rule 1"
  status    = "ACTIVE"
  enroll    = "CHALLENGE"
}

###################################
###    SECURITY NOTIFICATIONS   ###
###################################

resource "okta_security_notification_emails" "sec_notification_policy" {
  report_suspicious_activity_enabled       = true
  send_email_for_factor_enrollment_enabled = true
  send_email_for_factor_reset_enabled      = true
  send_email_for_new_device_enabled        = true
  send_email_for_password_changed_enabled  = true
}

###################################
###        THREAT INSIGHT       ###
###################################

resource "okta_threat_insight_settings" "threat_insight_setting" {
  action = "audit"
}