###############################################
# Minimal Gov: WAF ACL module
#
# このモジュールは、指定した CIDR からのみアクセスを許可する
# AWS WAFv2 Web ACL を作成します。
# - 許可 IP セット (aws_wafv2_ip_set)
# - 上記 IP セットを許可し、それ以外を遮断する Web ACL (aws_wafv2_web_acl)
#
# 主な用途:
# - ALB / API Gateway / AppSync など REGIONAL スコープのリソースに紐付け
# - ユーザ拠点など特定 CIDR のみにアクセスを制限
#
# 設計指針:
# - ロジックはできるだけ単純化
# - 変数化と豊富なコメントで可読性を重視
# - セキュリティ既定値: 許可リスト外のアクセスは Block
###############################################

###############################################
# Locals
# - base_name はリソース名やタグに利用する共通プレフィックス
###############################################
locals {
  base_name = var.name
}

###############################################
# 許可 IP セット
# - allow_cidrs で指定した CIDR のみを登録
# - IPv4 のみを想定（必要に応じてモジュール拡張）
###############################################
resource "aws_wafv2_ip_set" "allow" {
  name               = "${local.base_name}-allow"
  description        = "許可されたクライアント CIDR セット"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.allow_cidrs

  tags = merge(
    {
      Name = "${local.base_name}-allow-ipset"
    },
    var.tags,
  )
}

###############################################
# Web ACL 本体
# - デフォルトでは全トラフィックを Block
# - allow-cidr ルールで IP セット内のみ Allow
###############################################
resource "aws_wafv2_web_acl" "this" {
  name        = "${local.base_name}-acl"
  description = "allow_cidrs で指定した範囲のみを許可する WAF ACL"
  scope       = "REGIONAL"

  default_action {
    block {}
  }

  rule {
    name     = "allow-cidr"
    priority = 1

    action {
      allow {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.allow.arn
      }
    }

    visibility_config {
      metric_name                = "${local.base_name}-allow-cidr"
      cloudwatch_metrics_enabled = true # 標準で CloudWatch メトリクスを有効化
      sampled_requests_enabled   = true # 代表リクエストを記録（トラブルシュートに有用）
    }
  }

  visibility_config {
    metric_name                = local.base_name
    cloudwatch_metrics_enabled = true
    sampled_requests_enabled   = true
  }

  tags = merge(
    {
      Name = "${local.base_name}-acl"
    },
    var.tags,
  )
}

