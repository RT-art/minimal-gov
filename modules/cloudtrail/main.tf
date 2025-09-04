data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_region" "current" {}

locals {
  use_kms    = var.enable_kms_encryption
  create_kms = var.enable_kms_encryption && var.kms_key_arn == null
  bucket_arn = "arn:${data.aws_partition.current.partition}:s3:::${local.s3_bucket_name}"
  putobj_arn = var.is_organization_trail ? "${local.bucket_arn}/AWSLogs/*" : "${local.bucket_arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"

  s3_bucket_name = "cloudtrail-logs-${data.aws_caller_identity.current.account_id}-${data.aws_region.current.id}"
}

# ------------------------------------------------------------
# S3 bucket for CloudTrail logs 
# ------------------------------------------------------------
resource "aws_s3_bucket" "logs" {
  bucket = local.s3_bucket_name
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # バケット既定は SSE-S3（CloudTrail 本体は KMS で暗号化可能）
    }
  }
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule { object_ownership = "BucketOwnerEnforced" }
}

# CloudTrail 書き込み用の最小バケットポリシー
# バケットを覗く許可（GetBucketAcl）
# ログを書き込む許可（PutObject
data "aws_iam_policy_document" "trail_bucket" {
  statement {
    sid     = "AWSCloudTrailAclCheck"
    actions = ["s3:GetBucketAcl"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    resources = [local.bucket_arn]
  }
}
data "aws_iam_policy_document" "trail_write" {
  statement {
    sid     = "AWSCloudTrailWrite"
    actions = ["s3:PutObject"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }

    resources = [local.putobj_arn]
  }
}
data "aws_iam_policy_document" "logs_combined" {
  source_policy_documents   = [data.aws_iam_policy_document.trail_bucket.json]
  override_policy_documents = [data.aws_iam_policy_document.trail_write.json]

  statement {
    sid    = "AllowSSLRequestsOnly"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["s3:*"]
    resources = [local.bucket_arn, "${local.bucket_arn}/*"]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "logs" {
  bucket     = aws_s3_bucket.logs.id
  policy     = data.aws_iam_policy_document.logs_combined.json
  depends_on = [aws_s3_bucket_ownership_controls.logs]
}

# ------------------------------------------------------------
# (Optional) KMS key for CloudTrail SSE-KMS
# ------------------------------------------------------------
resource "aws_kms_key" "trail" {
  count               = local.create_kms ? 1 : 0
  description         = "KMS key for CloudTrail: ${var.trail_name}"
  enable_key_rotation = true
  tags                = var.tags

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnableRootPermissions"
        Effect    = "Allow"
        Principal = { AWS = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root" }
        Action    = "kms:*"
        Resource  = "*"
      },
      {
        Sid       = "AllowCloudTrail"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action = [
          "kms:GenerateDataKey*",
          "kms:Decrypt",
          "kms:DescribeKey"

        ]
        Resource = "*"
        Condition = {
          StringLike = {
            "kms:EncryptionContext:aws:cloudtrail:arn" = "arn:${data.aws_partition.current.partition}:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"
          }
        }
      }
    ]
  })
}

resource "aws_kms_alias" "trail" {
  count         = local.create_kms ? 1 : 0
  name          = "alias/cloudtrail-${var.trail_name}"
  target_key_id = aws_kms_key.trail[0].key_id
}

locals {
  kms_key_arn_effective = local.use_kms ? (var.kms_key_arn != null ? var.kms_key_arn : aws_kms_key.trail[0].arn) : null
}

# ------------------------------------------------------------
# CloudTrail
# ------------------------------------------------------------
resource "aws_cloudtrail" "this" {
  name                          = var.trail_name
  s3_bucket_name                = local.s3_bucket_name
  include_global_service_events = true
  enable_log_file_validation    = true
  is_multi_region_trail         = var.multi_region_trail
  is_organization_trail         = var.is_organization_trail
  enable_logging                = var.enable_logging
  insight_selector { insight_type = "ApiCallRateInsight" }
  insight_selector { insight_type = "ApiErrorRateInsight" }

  kms_key_id = local.kms_key_arn_effective
  depends_on = [aws_s3_bucket_policy.logs]

  tags = var.tags
}
