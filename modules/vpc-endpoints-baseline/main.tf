###############################################
# Minimal Gov: VPC Endpoints Baseline module
#
# このモジュールは、プライベート専用 VPC における「セキュアな VPC エンドポイントの標準セット」を
# 最小限の設定で一括作成します。上位の VPC モジュール（例: vpc-spoke）で作成した VPC/サブネット/ルートテーブル
# を入力として受け取り、以下を作成/構成します。
#
# 1) インターフェース型 VPC エンドポイント（Interface）: SSM/EC2 Messages/SSM Messages/KMS/Logs/ECR(DKR, API)/Secrets Manager/STS など
# 2) ゲートウェイ型 VPC エンドポイント（Gateway）: S3（デフォルト）
# 3) エンドポイント用セキュリティグループ: VPC 内クライアントからの 443/TCP のみ許可（既定）
#
# 設計指針：
# - ロジックはできる限り単純化（読みやすさ優先）
# - 変数化を徹底し、不要な分岐や複雑な式は避ける
# - セキュリティ既定値：Private DNS 有効、SG は 443 のみ許可
# - 出力は上位が依存する最小限（IDs のみ）
#
# 重要: このモジュール自身では VPC を作成しません。既存 VPC の ID、Interface 用サブネット IDs、
# Gateway 用ルートテーブル IDs を上位から渡してください。
###############################################

###############################################
# Data sources
# - リージョン名を取得し、サービスエンドポイント名を動的に組み立てます。
###############################################
data "aws_region" "current" {}

###############################################
# Locals
###############################################
locals {
  name_prefix = var.name_prefix != null && var.name_prefix != "" ? var.name_prefix : "vpce"

  # 有効化されたエンドポイントの集合（for_each 用）
  interface_services = var.enable_interface_endpoints ? toset(var.interface_endpoints) : toset([])
  gateway_services   = var.enable_gateway_endpoints ? toset(var.gateway_endpoints)   : toset([])
}

###############################################
# Security Group for Interface Endpoints
# - VPC 内のクライアントから 443/TCP を許可します（PrivateLink の既定ポート）。
# - エンドポイント ENI 自体にアタッチされ、到達性を制御します。
# - egress は明示的に許可（保守性とトラブルシュート容易性を優先）。
###############################################
resource "aws_security_group" "endpoints" {
  name        = "${local.name_prefix}-vpce"
  description = "Security group for VPC Interface Endpoints"
  vpc_id      = var.vpc_id

  # Inbound: 指定された CIDR ブロックから 443/TCP を許可
  dynamic "ingress" {
    for_each = var.allowed_cidrs
    content {
      description = "Allow HTTPS from VPC/approved CIDRs"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  # Outbound: すべて許可（PrivateLink ENI の動作を阻害しないため）
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "${local.name_prefix}-vpce-sg"
  }, var.tags)
}

###############################################
# Interface VPC Endpoints (PrivateLink)
# - 各サービスごとに 1 つのインターフェースエンドポイントを作成します。
# - Private DNS を既定で有効化（VPC 内から通常のサービス FQDN で解決できるように）。
# - セキュリティグループは上で作成した最小権限のものを適用。
###############################################
resource "aws_vpc_endpoint" "interface" {
  for_each = local.interface_services

  vpc_id              = var.vpc_id
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.key}"
  subnet_ids          = var.subnet_ids
  private_dns_enabled = var.enable_private_dns
  security_group_ids  = [aws_security_group.endpoints.id]

  tags = merge({
    Name = "${local.name_prefix}-${each.key}"
  }, var.tags)
}

###############################################
# Gateway VPC Endpoints
# - 代表的には S3/DynamoDB が対象。既定では S3 のみ。
# - ルートテーブルに自動関連付けします。
###############################################
resource "aws_vpc_endpoint" "gateway" {
  for_each = local.gateway_services

  vpc_id            = var.vpc_id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.${data.aws_region.current.name}.${each.key}"
  route_table_ids   = var.route_table_ids

  tags = merge({
    Name = "${local.name_prefix}-${each.key}"
  }, var.tags)
}

