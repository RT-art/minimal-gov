###############################################
# Transit Gateway
###############################################
module "tgw" {
  source = "../../../../modules/tgw-hub"
  # Transit Gateway 
  description                     = var.description
  amazon_side_asn                 = var.amazon_side_asn
  auto_accept_shared_attachments  = var.auto_accept_shared_attachments
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation
  tags                            = var.tags

  # Transit Gateway Route Tables
  route_tables             = var.route_tables
  route_table_associations = var.route_table_associations
  route_table_propagations = var.route_table_propagations

  # Route Table Association / Propagation 
  tgw_state = var.tgw_state
  vpc_state = var.vpc_state

  # AWS RAM 
  ram_principals                = var.ram_principals
  ram_share_name                = var.ram_share_name
  ram_allow_external_principals = var.ram_allow_external_principals
}

###############################################
# VPC
###############################################
module "vpc" {
  source = "../../../../modules/vpc"

  vpc_cidr            = var.vpc_cidr
  vpc_name            = var.vpc_name
  subnets             = var.subnets
  transit_gateway_id  = var.transit_gateway_id
  security_account_id = var.security_account_id
  log_format          = var.log_format
  tags                = var.tags
}

###############################################
# TGW Attachment
###############################################
module "tgw_attachment" {
  source = "../../../../modules/tgw-attachment"

  transit_gateway_id = module.tgw.tgw_id
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = local.tgw_attachment_subnet_ids
  attachment_name    = local.attachment_name
  tags               = var.tags
}

###############################################
# Endpoint
###############################################
module "endpoints" {
  source = "../../../../modules/endpoint"

  vpc_id         = module.vpc.vpc_id
  vpc_name       = module.vpc.vpc_name
  vpc_cidr       = module.vpc.vpc_cidr
  subnets        = module.vpc.subnets
  route_table_id = module.vpc.route_table_id
  tags           = var.tags

  endpoints = var.endpoints
}

###############################################
# VPN (ユーザ拠点)
###############################################
module "vpn" {
  source = "../../../../modules/vpn"

  env                 = var.env
  app_name            = var.app_name
  tags                = var.tags
  transit_gateway_id  = module.tgw.tgw_id
  customer_gateway_ip = var.customer_gateway_ip
  bgp_asn             = var.customer_gateway_bgp_asn
}
