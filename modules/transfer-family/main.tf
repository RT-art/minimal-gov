###############################################
# Minimal Gov: Transfer Family module
#
# このモジュールは、AWS Transfer Family SFTP サーバーと
# セキュアな S3 バケット、単一のサービス管理ユーザを
# 最小構成で提供します。
#
# - S3 バケットは暗号化とパブリックアクセスブロックを既定で有効化
# - CloudWatch Logs へ接続ログを出力
# - 指定した SSH 公開鍵で SFTP 接続可能なユーザを1つ作成
# - 複雑な設定を排し、読みやすさとセキュリティ既定値を重視
###############################################

###############################################
# Locals
###############################################
locals {
  # name_prefix は未指定なら "transfer" を利用
  name_prefix = var.name_prefix != null && var.name_prefix != "" ? var.name_prefix : "transfer"
}

###############################################
# S3 Bucket
# - SFTP ユーザのホームディレクトリとして利用
# - 暗号化とパブリックアクセスブロックをデフォルトで有効化
###############################################
resource "aws_s3_bucket" "this" {
  bucket = "${local.name_prefix}-bucket"

  tags = merge({
    Name = "${local.name_prefix}-bucket"
  }, var.tags)
}

# パブリックアクセスの完全遮断
resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 既定 KMS によるサーバーサイド暗号化
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

###############################################
# IAM ロール: CloudWatch Logs 出力用
###############################################
data "aws_iam_policy_document" "logging" {
  statement {
    effect    = "Allow"
    actions   = ["logs:CreateLogStream", "logs:PutLogEvents"]
    resources = ["arn:aws:logs:*:*:log-group:/aws/transfer/${local.name_prefix}*"]
  }
}

resource "aws_iam_role" "logging" {
  name = "${local.name_prefix}-logging-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "transfer.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  inline_policy {
    name   = "logging"
    policy = data.aws_iam_policy_document.logging.json
  }

  tags = merge({
    Name = "${local.name_prefix}-logging-role"
  }, var.tags)
}

###############################################
# IAM ロール: ユーザ用 S3 アクセス
# - transfer.amazonaws.com が引き受ける想定
###############################################
data "aws_iam_policy_document" "user_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["transfer.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "user_access" {
  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.this.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = ["${aws_s3_bucket.this.arn}/*"]
  }
}

resource "aws_iam_role" "user" {
  name               = "${local.name_prefix}-user-role"
  assume_role_policy = data.aws_iam_policy_document.user_assume.json

  inline_policy {
    name   = "s3-access"
    policy = data.aws_iam_policy_document.user_access.json
  }

  tags = merge({
    Name = "${local.name_prefix}-user-role"
  }, var.tags)
}

###############################################
# Transfer Family Server
###############################################
resource "aws_transfer_server" "this" {
  identity_provider_type = "SERVICE_MANAGED"
  logging_role           = aws_iam_role.logging.arn
  protocols              = var.protocols
  endpoint_type          = var.endpoint_type

  tags = merge({
    Name = "${local.name_prefix}-server"
  }, var.tags)
}

###############################################
# Transfer Family User
###############################################
resource "aws_transfer_user" "this" {
  server_id = aws_transfer_server.this.id
  user_name = var.user_name
  role      = aws_iam_role.user.arn

  # S3 バケット直下をホームディレクトリとして指定
  home_directory = "/${aws_s3_bucket.this.id}"

  tags = merge({
    Name = "${local.name_prefix}-${var.user_name}"
  }, var.tags)
}

# ユーザに SSH 公開鍵を関連付け
resource "aws_transfer_ssh_key" "this" {
  server_id = aws_transfer_server.this.id
  user_name = aws_transfer_user.this.user_name
  body      = var.ssh_public_key
}
