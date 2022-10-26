##################################
### ORGANIZATION CONFIGURATION ###
##################################

resource "okta_org_configuration" "this" {
  billing_contact_user         = "example"
  company_name                 = "example"
  opt_out_communication_emails = false
  technical_contact_user       = "example"
  website                      = "http://example.com"
}