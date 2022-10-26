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

#######################
### BOOKMARK LOCALS ###
#######################

locals {
  bookmarks = {
    "service_desk" = {
      bookmark_label  = "Service Desk",
      bookmark_status = "ACTIVE",
      url             = "https://example.com",
    }
    "dashboard" = {
      bookmark_label  = "Dashboard",
      bookmark_status = "ACTIVE",
      url             = "https://example.com",
    }
    "benefits" = {
      bookmark_label  = "Benefits",
      bookmark_status = "ACTIVE",
      url             = "https://example.com",
    }
    "sharepoint" = {
      bookmark_label  = "SharePoint",
      bookmark_status = "ACTIVE",
      url             = "https://example.com",
    "sie_yammer" = {
      bookmark_label  = "Siemens Yammer",
      bookmark_status = "ACTIVE",
      url             = "https://example.com",
    }
   }
  }
}

###############################
### GROUP ASSIGNMENT LOCALS ###
###############################

locals {
  bookmark_assignments = {
    "service_desk"   = { app_id = okta_app_bookmark.bookmark["service_desk"].id, group_id = data.terraform_remote_state.groups.outputs.functional_group["everyone"] }
    "dashboard"      = { app_id = okta_app_bookmark.bookmark["dashboard"].id, group_id = data.terraform_remote_state.groups.outputs.department_group["it"] }
    "sharepoint"     = { app_id = okta_app_bookmark.bookmark["sharepoint"].id, group_id = data.terraform_remote_state.groups.outputs.functional_group["everyone"] }
    "yammer"         = { app_id = okta_app_bookmark.bookmark["yammer"].id, group_id = data.terraform_remote_state.groups.outputs.functional_group["developers"] }
  }
}

#################
### BOOKMARKS ###
#################

resource "okta_app_bookmark" "bookmark" {
  for_each = local.bookmarks
  label    = each.value.bookmark_label
  status   = each.value.bookmark_status
  url      = each.value.url

  lifecycle {
    ignore_changes = [groups]
  }
}

resource "okta_app_group_assignment" "bookmark" {
  for_each = local.bookmark_assignments
  app_id   = each.value.app_id
  group_id = each.value.group_id
}