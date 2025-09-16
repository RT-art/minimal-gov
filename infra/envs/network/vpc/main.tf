
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
