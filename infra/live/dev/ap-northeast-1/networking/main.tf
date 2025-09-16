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

  # Transit Gateway
  transit_gateway_id = var.transit_gateway_id

  # VPC
  vpc_id     = module.vpc.vpc_id
  vpc_name   = module.vpc.vpc_name
  subnet_ids = module.vpc.subnet_ids

  # Feature flags
  dns_support                       = 
  ipv6_support                      = false
  appliance_mode_support            = false
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false

  # Metadata
  name_prefix = "prod"
  tags = {
    Environment = "prod"
    Application = "network"
    Owner       = "platform-team"
  }
}

###############################################
# Endpoints
###############################################
module "endpoints" {
  source = "../../../../modules/endpoint"

  vpc_id         = module.vpc.vpc_id
  vpc_name       = module.vpc.vpc_name
  vpc_cidr       = module.vpc.vpc_cidr
  subnets        = module.vpc.subnets
  route_table_id = module.vpc.route_table_id
  endpoints      = var.endpoints
  tags           = var.tags
}
