###############################################
# Minimal Gov: Route53 Private Hosted Zone (Service)
#
# このモジュールは、サービス公開向けの Route53 プライベートホストゾーンを作成します。
# 主な構成要素は以下の通りです。
#
# - 指定 VPC に関連付けられた Private Hosted Zone
# - サービスのエンドポイントを指し示す A/ALIAS レコード
# - （任意）AWS RAM によるアカウント間共有
#
# セキュリティ既定値:
# - ゾーンは常に Private として作成され、指定した VPC からのみ解決可能です。
# - 共有は `share_with_account_ids` を明示した場合のみ有効化されます。
###############################################

###############################################
# Locals
###############################################
locals {
  # アカウント共有を行うかどうか
  share_enabled = length(var.share_with_account_ids) > 0
}

###############################################
# Route53 Private Hosted Zone
###############################################
resource "aws_route53_zone" "this" {
  name = var.zone_name

  # Private Hosted Zone として指定 VPC に関連付け
  vpc {
    vpc_id = var.vpc_id
  }

  comment = "Service discovery private hosted zone"
  tags    = var.tags
}

###############################################
# DNS Records (A/ALIAS)
# - ALB や NLB などの DNS 名を登録します。
# - `records` 変数の内容に応じて動的に生成します。
###############################################
resource "aws_route53_record" "this" {
  for_each = { for r in var.records : r.name => r }

  zone_id = aws_route53_zone.this.zone_id
  name    = "${each.value.name}.${var.zone_name}"
  type    = each.value.type

  alias {
    name                   = each.value.alias_name
    zone_id                = each.value.alias_zone_id
    evaluate_target_health = false
  }
}

###############################################
# AWS RAM Sharing (optional)
# - `share_with_account_ids` が空でなければ、PHZ を他アカウントと共有します。
###############################################
resource "aws_ram_resource_share" "this" {
  count = local.share_enabled ? 1 : 0

  name                      = "${var.zone_name}-phz-share"
  allow_external_principals = true
  tags                      = var.tags
}

resource "aws_ram_principal_association" "this" {
  for_each = local.share_enabled ? toset(var.share_with_account_ids) : toset([])

  resource_share_arn = aws_ram_resource_share.this[0].arn
  principal          = each.value
}

resource "aws_ram_resource_association" "this" {
  count = local.share_enabled ? 1 : 0

  resource_share_arn = aws_ram_resource_share.this[0].arn
  resource_arn       = aws_route53_zone.this.arn
}
