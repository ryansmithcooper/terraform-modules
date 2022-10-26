###############
### OUTPUTS ###
###############

output "bookmark" {
  value = { for k, bookmark in okta_app_bookmark.bookmark : k => bookmark.id }
}