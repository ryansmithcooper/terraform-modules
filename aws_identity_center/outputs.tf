output "sso_arn" {
  value = tolist(data.aws_ssoadmin_instances.this.arns)[0]
}

output "sso_identity_store_id" {
  value = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
}

output "sso_id" {
  value = data.aws_ssoadmin_instances.this.id
}

output "sso_group" {
  value = { for k, group in data.aws_identitystore_group.this : k => group.id }
}