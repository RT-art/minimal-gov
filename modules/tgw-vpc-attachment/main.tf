###############################################
# Minimal Gov: TGW VPC Attachment module
#
# このモジュールは、既存の Transit Gateway (TGW) と既存の VPC の間に
# VPC アタッチメントを作成します。
# - aws_ec2_transit_gateway_vpc_attachment を 1 つ作成
# - セキュアな既定値として、TGW 既定 RT への自動関連付け/伝播は無効
# - DNS サポートは有効、IPv6/Appliance は用途に応じて選択
#
# ここではルートテーブルの関連付け/伝播（特定 RT への明示設定）は行いません。
# 経路制御は上位モジュール側で、aws_ec2_transit_gateway_route_table_association /
# aws_ec2_transit_gateway_route_table_propagation を用いて明示的に実施してください。
#
# 設計指針：
# - ロジックは可能な限り単純に（count/for_each の乱用を避ける）
# - 変数化を徹底し、読みやすい命名とコメント
# - セキュリティ既定値：TGW 既定 RT への自動関連付け/伝播は "disable"
# - 出力は上位で依存に必要な最小限（attachment_id 等）のみ
###############################################

###############################################
# TGW VPC Attachment
# - subnet_ids は 1 つ以上が必要ですが、冗長性のため 2 つ以上（異なる AZ）を推奨
###############################################
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  transit_gateway_id = var.transit_gateway_id
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids

  # 通常は DNS サポートを有効化（VPC 内の名前解決を TGW 越しに行う用途）
  dns_support             = var.dns_support
  # IPv6 を使わない場合は disable（環境の設計方針に合わせて選択）
  ipv6_support            = var.ipv6_support
  # FW アプライアンスの対向など特殊用途でのみ enable
  appliance_mode_support  = var.appliance_mode_support

  # セキュアな既定値：TGW の既定 RT には自動で関連付け/伝播させない
  transit_gateway_default_route_table_association = var.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = var.transit_gateway_default_route_table_propagation

  tags = merge(
    {
      Name = var.name != null && var.name != "" ? var.name : "tgw-vpc-attachment"
    },
    var.tags,
  )
}

