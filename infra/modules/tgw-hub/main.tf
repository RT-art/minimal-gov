###############################################
# Transit Gateway 
###############################################
resource "aws_ec2_transit_gateway" "this" {
  description                     = var.description
  amazon_side_asn                 = var.amazon_side_asn
  auto_accept_shared_attachments  = var.auto_accept_shared_attachments ? "enable" : "disable" # false -> "disable"に変換して、UX向上
  default_route_table_association = var.default_route_table_association ? "enable" : "disable"
  default_route_table_propagation = var.default_route_table_propagation ? "enable" : "disable"
  dns_support                     = "enable"
  vpn_ecmp_support                = "enable"
  tags = merge(
    var.tags,
    { Name = "${var.name_prefix}-tgw" }
  )
}
###############################################
# Transit Gateway Route Tables
###############################################
resource "aws_ec2_transit_gateway_route_table" "this" {
  for_each           = var.route_tables
  transit_gateway_id = aws_ec2_transit_gateway.this.id
  tags = merge(
    var.tags,
    { Name = "${var.name_prefix}-tgw-rtb-${each.value.name}" }
  )
}
###############################################
# Route Table Association / Propagation 
###############################################
# TGWに入ってくるトラフィックに対して、どのtgwルートテーブルを使うかを決める
resource "aws_ec2_transit_gateway_route_table_association" "this" {
  for_each = var.route_table_associations

  transit_gateway_attachment_id  = var.tgw_attachment_ids[each.value.vpc]
  transit_gateway_route_table_id = var.tgw_route_table_ids[each.value.route_table]
}

# そのアタッチメントのルート情報を、どのルートテーブルに 書き込むかを決める
resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  for_each = var.route_table_propagations

  transit_gateway_attachment_id  = var.tgw_attachment_ids[each.value.vpc]
  transit_gateway_route_table_id = var.tgw_route_table_ids[each.value.route_table]
}


###############################################
# AWS RAM
###############################################
resource "aws_ram_resource_share" "this" {
  count                     = length(var.ram_principals) > 0 ? 1 : 0
  name                      = var.ram_share_name
  allow_external_principals = false # TGW は外部アカウント不可
  tags = merge(
    var.tags,
    { Name = "${var.name_prefix}-tgw-ram" }
  )
}

resource "aws_ram_sharing_with_organization" "enable" {}

resource "aws_ram_principal_association" "this" {
  for_each           = var.ram_principals
  principal          = each.value
  resource_share_arn = aws_ram_resource_share.this[0].arn

  depends_on = [aws_ram_sharing_with_organization.enable]
}

resource "aws_ram_resource_association" "this" {
  count              = length(var.ram_principals) > 0 ? 1 : 0
  resource_arn       = aws_ec2_transit_gateway.this.arn
  resource_share_arn = aws_ram_resource_share.this[0].arn
}