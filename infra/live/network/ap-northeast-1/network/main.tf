module "network_vpc" {
  source                      = "../../../../modules/vpc-spoke"
  name_prefix                 = "network"
  vpc_cidr                    = var.vpc_cidr
  azs                         = var.azs
  private_subnet_count_per_az = var.private_subnet_count_per_az
  subnet_newbits              = var.subnet_newbits
  tags                        = var.tags
}

module "tgw" {
  source                          = "../../../../modules/tgw-hub"
  description                     = var.tgw_description
  amazon_side_asn                 = var.tgw_amazon_side_asn
  auto_accept_shared_attachments  = "disable"
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"
  tags                            = var.tags
}

module "tgw_attachment" {
  source                                          = "../../../../modules/tgw-vpc-attachment"
  transit_gateway_id                              = module.tgw.tgw_id
  vpc_id                                          = module.network_vpc.vpc_id
  subnet_ids                                      = [for az in var.azs : module.network_vpc.private_subnet_ids_by_az[az][0]]
  dns_support                                     = "enable"
  ipv6_support                                    = "disable"
  appliance_mode_support                          = "disable"
  transit_gateway_default_route_table_association = "disable"
  transit_gateway_default_route_table_propagation = "disable"
  tags                                            = var.tags
}

module "vpc_endpoints" {
  source                     = "../../../../modules/vpc-endpoints-baseline"
  vpc_id                     = module.network_vpc.vpc_id
  subnet_ids                 = [for az in var.azs : module.network_vpc.private_subnet_ids_by_az[az][0]]
  route_table_ids            = module.network_vpc.route_table_ids
  allowed_cidrs              = var.vpce_allowed_cidrs
  interface_endpoints        = var.interface_endpoints
  gateway_endpoints          = var.gateway_endpoints
  enable_interface_endpoints = true
  enable_gateway_endpoints   = true
  enable_private_dns         = true
  tags                       = var.tags
}
