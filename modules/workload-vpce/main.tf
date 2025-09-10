###############################################
# Minimal Gov: Workload VPC Endpoints module
#
# このモジュールは、アプリケーション VPC（例: ECS ワークロード）
# で必要となる最小限の VPC エンドポイントをまとめて作成します。
#
# - Interface 型: ECR (API/DKR)、Secrets Manager、CloudWatch Logs
# - Gateway 型: S3
#
# 入力として既存 VPC の ID、プライベートサブネット IDs、
# そしてエンドポイント ENI 用のセキュリティグループ ID を受け取ります。
# services 変数を指定しない場合は上記デフォルトセットを作成します。
#
# 設計指針:
# - ロジックは単純化し、可読性を最優先
# - Private DNS を既定で有効化（サービス FQDN 利用のため）
# - S3 Gateway Endpoint は指定サブネットに関連付くルートテーブルへ自動で関連付け
# - 出力は上位モジュールが依存する最小限の ID のみ
###############################################

###############################################
# Data sources
###############################################
# リージョン名を取得し、サービス名の組み立てに利用
# また、各サブネットに関連付くルートテーブルを取得します。
###############################################
data "aws_region" "current" {}

data "aws_route_table" "this" {
  for_each  = toset(var.subnet_ids)
  subnet_id = each.key
}

###############################################
# Locals
###############################################
locals {
  # サービス一覧: 引数 services が空または未指定ならデフォルトセット
  interface_services = length(var.services) > 0 ? var.services : [
    "ecr.api",
    "ecr.dkr",
    "secretsmanager",
    "logs",
  ]

  # S3 Gateway VPCE に関連付ける一意なルートテーブル ID
  route_table_ids = distinct([for rt in data.aws_route_table.this : rt.id])
}

###############################################
# Interface VPC Endpoints
# - 各サービスごとに 1 つのエンドポイントを作成
# - Private DNS は既定で有効化
# - セキュリティグループは外部で管理した ID を使用
###############################################
resource "aws_vpc_endpoint" "interface" {
  for_each = toset(local.interface_services)

  vpc_id              = var.vpc_id
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${data.aws_region.current.id}.${each.key}"
  subnet_ids          = var.subnet_ids
  security_group_ids  = [var.security_group_id]
  private_dns_enabled = true

  tags = merge({
    Name = "${each.key}-vpce"
  }, var.tags)
}

###############################################
# S3 Gateway VPC Endpoint
# - 指定サブネットに関連付くルートテーブルへ自動で関連付けます
###############################################
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = var.vpc_id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.${data.aws_region.current.id}.s3"
  route_table_ids   = local.route_table_ids

  tags = merge({
    Name = "s3-vpce"
  }, var.tags)
}
