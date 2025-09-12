###############################################
# Minimal Gov: TGW Hub module
#
# このモジュールは、Transit Gateway (TGW) を「ハブ」として作成し、
# 併せて用途別の TGW ルートテーブル（3 枚）を作成します。
# - TGW 本体
# - TGW ルートテーブル × 3（ユーザ向け/Spoke→Network/Network→Spoke）
#
# ここではアタッチメント（VPC/VPN/VGW）は作成しません。
# セキュアなデフォルトとして、TGW の「既定の関連付け/伝播」を無効化し、
# 明示的にルートテーブルへ関連付け/伝播する運用を前提とします。
#
# 設計指針：
# - ロジックは可能な限り単純に（count の乱用はしない）
# - 変数化を徹底し、読みやすさ重視
# - セキュリティ既定値：auto-accept 無効、既定の関連付け/伝播は無効
# - 出力は上位で参照が必要な最小限（tgw_id / 各 rt_id）に限定
###############################################

###############################################
# TGW 本体
# - dns_support / vpn_ecmp_support は一般的ユースケースのため有効化
# - auto_accept_shared_attachments は原則無効（意図せぬアタッチ防止）
# - default_route_table_association / propagation は無効（明示的制御を推奨）
###############################################
resource "aws_ec2_transit_gateway" "this" {
  description                     = var.description
  amazon_side_asn                 = var.amazon_side_asn
  auto_accept_shared_attachments  = var.auto_accept_shared_attachments
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation
  dns_support                     = var.dns_support
  vpn_ecmp_support                = var.vpn_ecmp_support

  tags = merge(
    {
      Name = var.name != null && var.name != "" ? var.name : "tgw-hub"
    },
    var.tags,
  )
}

###############################################
# TGW ルートテーブル（3 枚）
# - ネーミングは分かりやすさ優先。必要に応じて変数で上書き可能。
# - いずれも作成のみ。関連付け/伝播は上位モジュールで明示的に実施。
###############################################
resource "aws_ec2_transit_gateway_route_table" "user" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id

  tags = merge(
    {
      Name = var.rt_name_user
      Role = "user"
    },
    var.tags,
  )
}

resource "aws_ec2_transit_gateway_route_table" "spoke_to_network" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id

  tags = merge(
    {
      Name = var.rt_name_spoke_to_network
      Role = "spoke-to-network"
    },
    var.tags,
  )
}

resource "aws_ec2_transit_gateway_route_table" "network_to_spoke" {
  transit_gateway_id = aws_ec2_transit_gateway.this.id

  tags = merge(
    {
      Name = var.rt_name_network_to_spoke
      Role = "network-to-spoke"
    },
    var.tags,
  )
}

###############################################
# Optional: AWS RAM share for TGW
###############################################
resource "aws_ram_resource_share" "this" {
  count                     = length(var.ram_principals) > 0 ? 1 : 0
  name                      = var.ram_share_name
  allow_external_principals = var.ram_allow_external_principals
  tags                      = var.tags
}

resource "aws_ram_principal_association" "this" {
  for_each           = length(var.ram_principals) > 0 ? { for idx, principal in var.ram_principals : idx => principal } : {}
  principal          = each.value
  resource_share_arn = aws_ram_resource_share.this[0].arn
}

resource "aws_ram_resource_association" "this" {
  count              = length(var.ram_principals) > 0 ? 1 : 0
  resource_arn       = aws_ec2_transit_gateway.this.arn
  resource_share_arn = aws_ram_resource_share.this[0].arn
}

###############################################
# Optional: TGW route table association/propagation
###############################################
resource "aws_ec2_transit_gateway_route_table_association" "this" {
  for_each                       = { for idx, assoc in var.route_table_associations : idx => assoc }
  transit_gateway_attachment_id  = each.value.transit_gateway_attachment_id
  transit_gateway_route_table_id = each.value.transit_gateway_route_table_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "this" {
  for_each                       = { for idx, prop in var.route_table_propagations : idx => prop }
  transit_gateway_attachment_id  = each.value.transit_gateway_attachment_id
  transit_gateway_route_table_id = each.value.transit_gateway_route_table_id
}

