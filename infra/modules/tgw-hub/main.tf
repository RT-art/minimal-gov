###############################################
# Transit Gateway 
###############################################
resource "aws_ec2_transit_gateway" "this" {
  description                     = var.description
  amazon_side_asn                 = var.amazon_side_asn
  auto_accept_shared_attachments  = var.auto_accept_shared_attachments
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"

  tags = var.tags
}
###############################################
# Transit Gateway Route Tables
###############################################
resource "aws_ec2_transit_gateway_route_table" "this" {
  for_each           = var.route_tables
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  tags = merge(
    {
      Name  = each.value.name
      scope = each.value.scope
    },
    var.tags,
  )
}
###############################################
# Route Table Association / Propagation 
###############################################
resource "aws_ec2_transit_gateway_route_table_association" "this" {
  for_each = { for assoc in var.route_table_associations : "${assoc.vpc}-${assoc.route_table}" => assoc }

  transit_gateway_attachment_id  = data.terraform_remote_state.vpc.outputs["${each.value.vpc}_tgw_attachment_id"]
  transit_gateway_route_table_id = data.terraform_remote_state.tgw.outputs.tgw_route_table_ids[each.value.route_table]
}

resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  for_each = { for prop in var.route_table_propagations : "${prop.vpc}-${prop.route_table}" => prop }

  transit_gateway_attachment_id  = data.terraform_remote_state.vpc.outputs["${each.value.vpc}_tgw_attachment_id"]
  transit_gateway_route_table_id = data.terraform_remote_state.tgw.outputs.tgw_route_table_ids[each.value.route_table]
}

###############################################
# AWS RAM 
###############################################
resource "aws_ram_resource_share" "this" {
  count                     = length(var.ram_principals) > 0 ? 1 : 0
  name                      = var.ram_share_name
  allow_external_principals = var.ram_allow_external_principals
  tags                      = var.tags
}

resource "aws_ram_principal_association" "this" {
  for_each           = var.ram_principals
  principal          = each.value
  resource_share_arn = aws_ram_resource_share.this[0].arn
}

resource "aws_ram_resource_association" "this" {
  count              = length(var.ram_principals) > 0 ? 1 : 0
  resource_arn       = aws_ec2_transit_gateway.this.arn
  resource_share_arn = aws_ram_resource_share.this[0].arn
}


