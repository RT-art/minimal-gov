###############################################
# Transit Gateway Route Tables
###############################################
resource "aws_ec2_transit_gateway_route_table" "this" {
  for_each           = { for rt in var.route_tables : rt.name => rt } # 変数を書きやすくしたいため、listから変換
  transit_gateway_id = var.transit_gateway_id
  tags = merge(
    var.tags,
    { Name = "${var.app_name}-${var.env}-tgw-rtb-${each.value.name}" }
  )
}
###############################################
# Route Table Association / Propagation 
###############################################
# 関連付け
resource "aws_ec2_transit_gateway_route_table_association" "this" {
  for_each = {
    for assoc in var.route_table_associations :
    "${assoc.vpc}-${assoc.route_table}" => assoc
  } # 変数を書きやすくしたいため、listから変換
  transit_gateway_attachment_id  = var.tgw_attachment_ids[each.value.vpc]
  transit_gateway_route_table_id = var.tgw_route_table_ids[each.value.route_table]
}

# 伝播
resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  for_each = {
    for prop in var.route_table_propagations :
    "${prop.vpc}-${prop.route_table}" => prop
  } # 変数を書きやすくしたいため、listから変換
  transit_gateway_attachment_id  = var.tgw_attachment_ids[each.value.vpc]
  transit_gateway_route_table_id = var.tgw_route_table_ids[each.value.route_table]
}
