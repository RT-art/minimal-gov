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
locals {
  tgw_attachment_subnet_ids = [
    for sn in var.tgw_attachment_subnet_names :
    module.vpc.subnets[sn].id
  ]
  attachment_name = "${var.app_name}-${var.env}-tgw-attach"
}

module "tgw_attachment" {
  source = "../../../../modules/tgw-vpc-attachment"

  transit_gateway_id = var.transit_gateway_id
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = local.tgw_attachment_subnet_ids
  attachment_name    = local.attachment_name
  tags               = var.tags
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
