###############################################
# Transit Gateway
###############################################
module "tgw" {
  source = "../../../modules/tgw-hub"

  # Transit Gateway 
  description                     = var.description
  amazon_side_asn                 = var.amazon_side_asn
  auto_accept_shared_attachments  = var.auto_accept_shared_attachments
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation

  # Metadata
  name_prefix = var.name_prefix
  tags        = var.tags

  # Transit Gateway Route Tables
  route_tables             = var.route_tables
  route_table_associations = var.route_table_associations
  route_table_propagations = var.route_table_propagations

  # Route Table Association / Propagation 
  tgw_attachment_ids  = var.tgw_attachment_ids
  tgw_route_table_ids = var.tgw_route_table_ids

  # AWS RAM 
  ram_share_name                = var.ram_share_name
}
