################
###  GENERAL ###
################

variable "name" {
  type        = string
  description = "The name of the application or service being deployed."
  default     = "client_vpn"

}

variable "region" {
  type        = string
  description = "The region of the AWS account where the internal VPN will be deployed."
  default     = "us-east-1"
}

##################
### CLOUDWATCH ###
##################

variable "enable_connection_logs" {
  type    = bool
  default = true
}

variable "log_retention_days" {
  type    = number
  default = 0
}

###########
### VPC ###
###########

variable "vpc_cidr" {}

variable "subnets" {}

variable "routes_cidr" {
  type = set(string)
}

variable "use_tgw" {
  type = bool
}

variable "gateway_id" {}

variable "sg_rules" {
  type        = map(any)
  description = "The region of the AWS account where the internal VPN will be deployed."
  default = {
    "allow_all" = {
      type            = "egress",
      from_port       = 0,
      to_port         = 0,
      protocol        = "-1",
      cidr_blocks     = ["0.0.0.0/0"]
      ipv6_cidr_block = ["::/0"]
    }
  }
}

##################
### CLIENT VPN ###
##################

variable "client_cidr" {}

variable "dns_servers" {
  type    = list(any)
  default = ["169.254.169.253", "8.8.8.8"]
}

variable "session_timeout_hours" {
  type    = number
  default = 8
}

variable "use_split_tunnel" {
  type    = bool
  default = true
}

variable "transport_protocol" {
  type    = string
  default = "udp"
}

variable "vpn_port" {
  type    = number
  default = 443
}

variable "client_connect_options_enabled" {
  type    = bool
  default = false
}

variable "client_connect_lambda_arn" {
  type    = string
  default = ""
}

variable "client_login_banner_enabled" {
  type    = bool
  default = false
}

variable "client_login_banner_text" {
  type    = string
  default = ""
}

variable "use_default_client_vpn_auth_rule" {
  type    = bool
  default = true
}

#############
### FILES ###
##############

variable "saml_metadata_path" {}

variable "cert_chain_path" {}

variable "server_cert_body_path" {}

variable "server_private_key_path" {}

############
### TAGS ###
############

variable "tag_application" {
  type    = string
  default = ""
}

variable "tag_environment" {
  type    = string
  default = ""
}

variable "tag_owner" {
  type    = string
  default = ""
}

variable "tag_service" {
  type    = string
  default = ""
}

variable "tag_version" {
  type    = string
  default = ""
}

variable "tag_map_server_id" {
  type    = string
  default = ""
}