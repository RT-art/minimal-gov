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
  ram_principals                  = var.tgw_ram_principals
}

module "network_vpc" {
  source                      = "../../../../modules/vpc-spoke"
  vpc_name                    = "network"
  vpc_cidr                    = var.vpc_cidr
  azs                         = var.azs
  private_subnet_count_per_az = var.private_subnet_count_per_az
  subnet_newbits              = var.subnet_newbits
  tags                        = var.tags
  transit_gateway_id          = module.tgw.tgw_id
  tgw_destination_cidrs       = var.tgw_destination_cidrs
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

###############################################
# TGW route table association and propagation
###############################################
resource "aws_ec2_transit_gateway_route_table_association" "network" {
  transit_gateway_attachment_id  = module.tgw_attachment.attachment_id
  transit_gateway_route_table_id = module.tgw.rt_network_to_spoke_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "network" {
  transit_gateway_attachment_id  = module.tgw_attachment.attachment_id
  transit_gateway_route_table_id = module.tgw.rt_spoke_to_network_id
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
