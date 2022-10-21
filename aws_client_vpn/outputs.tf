###########
### VPC ###
###########

output "vpc_id" {
  value = aws_vpc.this.id
}

output "vpc_arn" {
  value = aws_vpc.this.arn
}

###############
### SUBNETS ###
###############

output "subnet_cidrs" {
  value = { for k, subnet in aws_subnet.this : k => subnet.cidr_block }
}

output "subnet_ids" {
  value = [for k, subnet in aws_subnet.this : subnet.id]
}

output "subnet_arns" {
  value = { for k, subnet in aws_subnet.this : k => subnet.arn }
}

######################
### SECURITY GROUP ###
######################

output "security_group_id" {
  value = aws_security_group.this.id
}

output "security_group_arn" {
  value = aws_security_group.this.arn
}

##################
### CLIENT VPN ###
##################

output "client_vpn_id" {
  value = aws_ec2_client_vpn_endpoint.this.id
}

output "client_vpn_arn" {
  value = aws_ec2_client_vpn_endpoint.this.arn
}

output "client_vpn_cidr" {
  value = aws_ec2_client_vpn_endpoint.this.client_cidr_block
}

output "client_vpn_dns_name" {
  value = aws_ec2_client_vpn_endpoint.this.dns_name
}