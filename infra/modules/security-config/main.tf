###############################################
# security-config module
#
# このモジュールは AWS Config を組織管理アカウントで有効化するための最小構成です。
# 以下のリソースを作成します:
# - (任意) AWS Config 配信用の S3 バケット（暗号化・公開ブロック済み）
# - Config Recorder とその IAM ロール
# - 配信チャネル (Delivery Channel) とスナップショット頻度設定
# - 組織全体の設定を集約する Config Aggregator とその IAM ロール
# すべてのリソースはセキュアな既定値で作成され、作成後に記録を自動開始します。
###############################################

terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.9"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Application = var.app_name
      Environment = var.env
      ManagedBy   = "Terraform"
      Region      = var.region
    }
  }
}

###############################################
# S3 bucket for AWS Config (optional)
#
# セキュリティ既定値として、暗号化・バージョニング・公開ブロックを有効化。
# create_bucket=false の場合は、既存バケット (var.bucket_name) を利用します。
###############################################
resource "aws_s3_bucket" "config" {
  count  = var.create_bucket ? 1 : 0
  bucket = var.bucket_name
  tags   = var.tags
}

# 全ての公開アクセスをブロック
resource "aws_s3_bucket_public_access_block" "config" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.config[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# バージョニングを有効化
resource "aws_s3_bucket_versioning" "config" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.config[0].id
  versioning_configuration {
    status = "Enabled"
  }
}

# サーバーサイド暗号化 (SSE-S3)
resource "aws_s3_bucket_server_side_encryption_configuration" "config" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.config[0].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

###############################################
# IAM Role for Config Recorder
###############################################

# Config サービスが Assume するロール
resource "aws_iam_role" "recorder" {
  name               = "AWSConfigRecorderRole"
  assume_role_policy = data.aws_iam_policy_document.recorder_assume.json
}

data "aws_iam_policy_document" "recorder_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

# 推奨マネージドポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "recorder" {
  role       = aws_iam_role.recorder.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRole"
}

###############################################
# Config Recorder & Delivery Channel
###############################################
resource "aws_config_configuration_recorder" "this" {
  name     = "config-recorder"
  role_arn = aws_iam_role.recorder.arn
  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "this" {
  name           = "config-delivery"
  s3_bucket_name = var.bucket_name

  snapshot_delivery_properties {
    delivery_frequency = var.snapshot_delivery_frequency
  }

  depends_on = [aws_config_configuration_recorder.this]
}

# Recorder を有効化
resource "aws_config_configuration_recorder_status" "this" {
  name       = aws_config_configuration_recorder.this.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.this]
}

###############################################
# IAM Role for Aggregator
###############################################
resource "aws_iam_role" "aggregator" {
  name               = var.aggregator_role_name
  assume_role_policy = data.aws_iam_policy_document.aggregator_assume.json
}

data "aws_iam_policy_document" "aggregator_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "aggregator" {
  role       = aws_iam_role.aggregator.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}

###############################################
# Organization Config Aggregator
###############################################
resource "aws_config_configuration_aggregator" "this" {
  name = "org-config-aggregator"
  organization_aggregation_source {
    all_regions = true
    role_arn    = aws_iam_role.aggregator.arn
  }
}

