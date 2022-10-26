###############
### OUTPUTS ###
###############

output "functional_group" {
  value = { for k, functional in okta_group.functional : k => functional.id }
}

output "department_group" {
  value = { for k, department in okta_group.department : k => department.id }
}

output "application_group" {
  value = { for k, application in okta_group.application : k => application.id }
}