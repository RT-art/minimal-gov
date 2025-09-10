###############################################
# Minimal Gov: Secrets Baseline module
#
# このモジュールは、AWS Secrets Manager を用いてアプリケーションやデータベースの
# シークレットを簡易かつ安全に管理するためのベースラインを提供します。
# 複数のシークレットを一括作成し、必要に応じてローテーション設定を有効化できます。
#
# 作成するリソース:
# - aws_secretsmanager_secret: シークレットのメタデータ
# - aws_secretsmanager_secret_version: 初期シークレット値
# - (オプション) aws_secretsmanager_secret_rotation: ローテーション設定
#
# 設計指針:
# - ロジックは可能な限り単純化し、可読性を優先
# - セキュリティ既定値として暗号化は AWS 管理キーを使用 (追加設定不要)
# - 出力は上位モジュールが依存する最小限（ARN のみ）
###############################################

###############################################
# Locals
###############################################
locals {
  # シークレット名などに付与するプレフィックス。未指定時は "secret"
  name_prefix = var.name_prefix != null && var.name_prefix != "" ? var.name_prefix : "secret"

  # 入力されたシークレットマップを明示的に tomap し、型のばらつきを許容
  secrets_map = tomap(var.secrets)

  # シークレットの値を文字列化
  # - 値が文字列の場合はそのまま利用
  # - 値がオブジェクト/マップの場合は JSON 文字列へ変換
  secret_payloads = {
    for k, v in local.secrets_map :
    k => (can(regex("", v)) ? v : jsonencode(v))
  }
}

###############################################
# Secrets Manager: Secret definition
###############################################
resource "aws_secretsmanager_secret" "this" {
  for_each = local.secrets_map

  name        = "${local.name_prefix}-${each.key}"
  description = "Managed secret for ${each.key}"

  tags = merge({
    Name = "${local.name_prefix}-${each.key}"
  }, var.tags)
}

###############################################
# Secrets Manager: Initial value
###############################################
resource "aws_secretsmanager_secret_version" "this" {
  for_each = aws_secretsmanager_secret.this

  secret_id     = each.value.id
  secret_string = local.secret_payloads[each.key]
}

###############################################
# Secrets Manager: Rotation (optional)
# enable_rotation が true の場合のみ作成します。
###############################################
resource "aws_secretsmanager_secret_rotation" "this" {
  for_each = var.enable_rotation ? aws_secretsmanager_secret.this : {}

  secret_id           = each.value.id
  rotation_lambda_arn = var.rotation_lambda_arn

  rotation_rules {
    automatically_after_days = var.rotation_days
  }
}

