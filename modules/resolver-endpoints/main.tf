###############################################
# Minimal Gov: Resolver Endpoints module
#
# このモジュールは、指定された VPC に Route 53 Resolver Endpoints を作成します。
# 典型的なユースケース（ハイブリッド DNS）に合わせ、以下をシンプルに提供します。
#
# - Inbound Resolver Endpoint（オンプレミス/他ネットワークからのクエリを受ける）
# - Outbound Resolver Endpoint（VPC から外部 DNS へフォワードする際に利用）
# - セキュリティグループ（既定で作成し、必要最小限のルールを適用）
#
# 設計指針：
# - ロジックは可能な限り単純化（読みやすさ優先、count 乱用を避ける）
# - 変数化を徹底し、上位モジュールから明示入力できるようにする
# - セキュリティ既定値：Inbound は明示許可 CIDR からの 53/TCP+UDP のみ許可（未指定なら閉鎖）
#   Outbound 用 SG の egress は既定許可（フォワード先の到達性を阻害しないため）
# - 出力は上位が依存する最小限（SG ID / 各 Endpoint ID）
#
# 重要: このモジュールはルール（Resolver rules）やその関連付けは作成しません。
#       ドメイン単位のフォワーディングや共有は上位側で実装してください。
###############################################

###############################################
# Locals
###############################################
locals {
  name_prefix = var.name_prefix != null && var.name_prefix != "" ? var.name_prefix : "resolver"

  # 既存 SG を使うか、このモジュールで新規作成するか
  use_existing_sg = var.security_group_id != null && var.security_group_id != ""
}

###############################################
# Security Group
# - Inbound Endpoint 用に 53/TCP+UDP を "許可元 CIDR" からのみ開放します。
# - Outbound での通信を阻害しないよう、egress は許可します。
# - 既存 SG を使いたい場合は `security_group_id` を渡してください（その場合ルールは作成しません）。
###############################################
resource "aws_security_group" "resolver" {
  count       = local.use_existing_sg ? 0 : 1
  name        = "${local.name_prefix}-rslvr"
  description = "Security group for Route53 Resolver Endpoints"
  vpc_id      = var.vpc_id

  # Outbound: すべて許可（Resolver の名前解決を阻害しないため）
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "${local.name_prefix}-resolver-sg"
  }, var.tags)
}

# Inbound: 53/TCP を許可（必要な場合のみ作成）
resource "aws_vpc_security_group_ingress_rule" "dns_tcp" {
  for_each = local.use_existing_sg || !var.create_inbound ? {} : toset(var.inbound_allowed_cidrs)

  security_group_id = local.use_existing_sg ? var.security_group_id : aws_security_group.resolver[0].id
  description       = "Allow DNS over TCP from approved CIDR"
  ip_protocol       = "tcp"
  from_port         = 53
  to_port           = 53
  cidr_ipv4         = each.value
}

# Inbound: 53/UDP を許可（必要な場合のみ作成）
resource "aws_vpc_security_group_ingress_rule" "dns_udp" {
  for_each = local.use_existing_sg || !var.create_inbound ? {} : toset(var.inbound_allowed_cidrs)

  security_group_id = local.use_existing_sg ? var.security_group_id : aws_security_group.resolver[0].id
  description       = "Allow DNS over UDP from approved CIDR"
  ip_protocol       = "udp"
  from_port         = 53
  to_port           = 53
  cidr_ipv4         = each.value
}

###############################################
# Resolver Endpoints
# - Inbound: オンプレ等からのクエリを受けるために作成（方向 INBOUND）
# - Outbound: 外部の DNS へ転送するために作成（方向 OUTBOUND）
# - IP アドレスは各サブネットで自動割当。少なくとも 2 つの AZ を推奨。
###############################################
resource "aws_route53_resolver_endpoint" "inbound" {
  count = var.create_inbound ? 1 : 0

  name               = "${local.name_prefix}-inbound"
  direction          = "INBOUND"
  security_group_ids = [local.use_existing_sg ? var.security_group_id : aws_security_group.resolver[0].id]

  dynamic "ip_address" {
    for_each = var.inbound_subnet_ids
    content {
      subnet_id = ip_address.value
    }
  }

  tags = merge({
    Name = "${local.name_prefix}-inbound"
  }, var.tags)
}

resource "aws_route53_resolver_endpoint" "outbound" {
  count = var.create_outbound ? 1 : 0

  name               = "${local.name_prefix}-outbound"
  direction          = "OUTBOUND"
  security_group_ids = [local.use_existing_sg ? var.security_group_id : aws_security_group.resolver[0].id]

  dynamic "ip_address" {
    for_each = var.outbound_subnet_ids
    content {
      subnet_id = ip_address.value
    }
  }

  tags = merge({
    Name = "${local.name_prefix}-outbound"
  }, var.tags)
}

