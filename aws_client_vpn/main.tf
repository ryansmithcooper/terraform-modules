#########################
### LOCAL DEFINITIONS ###
#########################

locals {
  subnet_id_map = { for k, subnet in aws_ec2_client_vpn_network_association.this : k => subnet.subnet_id }

  subnet_route_pairs = flatten([
    for name,subnet_id in local.subnet_id_map : [
      for cidr in var.routes_cidr : {
        subnet_id = subnet_id
        cidr      = cidr
        name      = name
      }
    ]
  ])

  route_association_map = {
    for obj in local.subnet_route_pairs : "${obj.name}_${obj.cidr}" => obj
  }
}

###############
### MODULES ###
###############

module "tags" {
  source = "git::ssh://git@bitbucket.org/enlightedinc/terraform-common-tags.git?ref=v1.1.0"

  tag_application   = var.tag_application
  tag_environment   = var.tag_environment
  tag_name          = var.name
  tag_owner         = var.tag_owner
  tag_service       = var.tag_service
  tag_version       = var.tag_version
  tag_map_server_id = var.tag_map_server_id
}

####################
### CERTIFICATES ###
####################

resource "aws_acm_certificate" "server" {
  private_key       = file(var.server_private_key_path)
  certificate_body  = file(var.server_cert_body_path)
  certificate_chain = file(var.cert_chain_path)

  tags = merge(module.tags.tags, {
    Name = format("%s_%s", var.name, "server_cert")
  })

  lifecycle {
    create_before_destroy = true
  }
}

########################
### SAML INTEGRATION ###
########################

resource "aws_iam_saml_provider" "this" {
  name                   = format("%s_%s", var.name, "idp")
  saml_metadata_document = file(var.saml_metadata_path)
}

##################
### CLOUDWATCH ###
##################

resource "aws_cloudwatch_log_group" "this" {
  count             = var.enable_connection_logs ? 1 : 0
  name              = format("%s_%s", var.name, "log_group")
  retention_in_days = var.log_retention_days

  tags = merge(module.tags.tags, {
    Name = format("%s_%s", var.name, "log_group")
  })
}

resource "aws_cloudwatch_log_stream" "this" {
  count          = var.enable_connection_logs ? 1 : 0
  name           = format("%s_%s", var.name, "log_stream")
  log_group_name = aws_cloudwatch_log_group.this[0].name
}

###########
### VPC ###
###########

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = merge(module.tags.tags, {
    Name = format("%s_%s", var.name, "vpc")
  })
}

###############
### SUBNETS ###
###############

resource "aws_subnet" "this" {
  for_each                = var.subnets
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = merge(module.tags.tags, {
    Name = each.key
  })
}

#######################
### SECURITY GROUPS ###
#######################

resource "aws_security_group" "this" {
  name   = format("%s_%s", var.name, "sg")
  vpc_id = aws_vpc.this.id

  tags = merge(module.tags.tags, {
    Name = format("%s_%s", var.name, "sg")
  })
}

resource "aws_security_group_rule" "this" {
  for_each          = var.sg_rules
  security_group_id = aws_security_group.this.id
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  ipv6_cidr_blocks  = each.value.ipv6_cidr_block
}

####################
### ROUTE TABLES ###
####################

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(module.tags.tags, {
    Name = format("%s_%s", "rtb", var.name)
  })
}

resource "aws_route_table_association" "this" {
  for_each       = aws_subnet.this
  subnet_id      = each.value.id
  route_table_id = aws_route_table.this.id
}

resource "aws_route" "this_gw" {
  for_each               = var.use_tgw ? [] : var.routes_cidr
  route_table_id         = aws_route_table.this.id
  destination_cidr_block = each.key
  gateway_id             = var.gateway_id
}

resource "aws_route" "this_tgw" {
  for_each               = var.use_tgw ? var.routes_cidr : []
  route_table_id         = aws_route_table.this.id
  destination_cidr_block = each.key
  transit_gateway_id     = var.gateway_id
}

##################
### CLIENT VPN ###
##################

resource "aws_ec2_client_vpn_endpoint" "this" {
  client_cidr_block      = var.client_cidr
  dns_servers            = var.dns_servers
  security_group_ids     = [aws_security_group.this.id]
  server_certificate_arn = aws_acm_certificate.server.arn
  session_timeout_hours  = var.session_timeout_hours
  split_tunnel           = var.use_split_tunnel
  transport_protocol     = var.transport_protocol
  vpc_id                 = aws_vpc.this.id
  vpn_port               = var.vpn_port

  tags = merge(module.tags.tags, {
    Name = var.name
  })

  authentication_options {
    type                           = "federated-authentication"
    saml_provider_arn              = aws_iam_saml_provider.this.arn
    self_service_saml_provider_arn = aws_iam_saml_provider.this.arn
  }

  client_connect_options {
    enabled             = var.client_connect_options_enabled
    lambda_function_arn = var.client_connect_lambda_arn
  }

  client_login_banner_options {
    banner_text = var.client_login_banner_text
    enabled     = var.client_login_banner_enabled
  }

  connection_log_options {
    cloudwatch_log_group  = aws_cloudwatch_log_group.this[0].name
    cloudwatch_log_stream = aws_cloudwatch_log_stream.this[0].name
    enabled               = var.enable_connection_logs
  }
}

resource "aws_ec2_client_vpn_authorization_rule" "this" {
  count                  = var.use_default_client_vpn_auth_rule ? 1 : 0
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  target_network_cidr    = "0.0.0.0/0"
  authorize_all_groups   = true
}

resource "aws_ec2_client_vpn_network_association" "this" {
  for_each               = aws_subnet.this
  subnet_id              = each.value.id
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
}

resource "aws_ec2_client_vpn_route" "this" {
  for_each               = local.route_association_map
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.this.id
  destination_cidr_block = each.value.cidr
  target_vpc_subnet_id   = each.value.subnet_id
}