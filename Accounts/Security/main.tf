# 中央集権セキュリティリソース作成

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  cloudtrail_s3_bucket_name = "ct-logs-${data.aws_caller_identity.current.account_id}-${var.region}"
  config_s3_bucket_name     = "config-logs-${data.aws_caller_identity.current.account_id}-${var.region}"
  config_service_linked_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/config.amazonaws.com/AWSServiceRoleForConfig"
}

########################
# CloudTrail (Organization trail)
########################
# S3 bucket for CloudTrail logs
resource "aws_s3_bucket" "cloudtrail" {
  bucket = local.cloudtrail_s3_bucket_name
}

resource "aws_s3_bucket_ownership_controls" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "cloudtrail" {
  bucket                  = aws_s3_bucket.cloudtrail.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "cloudtrail_bucket" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.cloudtrail.arn]
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.cloudtrail.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail" {
  bucket = aws_s3_bucket.cloudtrail.id
  policy = data.aws_iam_policy_document.cloudtrail_bucket.json
}

resource "aws_cloudtrail" "org" {
  name                          = var.trail_name
  s3_bucket_name                = aws_s3_bucket.cloudtrail.bucket
  is_organization_trail         = true
  enable_logging                = var.enable_logging
  enable_log_file_validation    = true
  include_global_service_events = true
  is_multi_region_trail         = true
  depends_on                    = [aws_s3_bucket_policy.cloudtrail]
  tags                          = var.tags
}

########################
# AWS Config (Recorder + Delivery)
########################
# S3 bucket for AWS Config
resource "aws_s3_bucket" "config" {
  bucket = local.config_s3_bucket_name
}

resource "aws_s3_bucket_ownership_controls" "config" {
  bucket = aws_s3_bucket.config.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "config" {
  bucket                  = aws_s3_bucket.config.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_iam_policy_document" "config_bucket" {
  statement {
    sid    = "AWSConfigBucketPermissionsCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.config.arn]
  }

  statement {
    sid    = "AWSConfigBucketDelivery"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.config.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
  }
}

resource "aws_s3_bucket_policy" "config" {
  bucket = aws_s3_bucket.config.id
  policy = data.aws_iam_policy_document.config_bucket.json
}

# Ensure the service-linked role exists (created automatically when enabling Config)
resource "aws_iam_service_linked_role" "config" {
  aws_service_name = "config.amazonaws.com"
}

resource "aws_config_configuration_recorder" "this" {
  name     = "default"
  role_arn = local.config_service_linked_arn
  depends_on = [aws_iam_service_linked_role.config]

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_config_delivery_channel" "this" {
  name           = "default"
  s3_bucket_name = aws_s3_bucket.config.bucket
  depends_on     = [aws_config_configuration_recorder.this]

  snapshot_delivery_properties {
    delivery_frequency = "TwentyFour_Hours"
  }
}

resource "aws_config_configuration_recorder_status" "this" {
  name       = aws_config_configuration_recorder.this.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.this]
}

########################
# AWS Config Aggregator (Organization)
########################
data "aws_iam_policy_document" "config_aggregator_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "config_aggregator" {
  name               = var.config_aggregator_role_name
  assume_role_policy = data.aws_iam_policy_document.config_aggregator_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "config_aggregator" {
  role       = aws_iam_role.config_aggregator.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}

resource "aws_config_configuration_aggregator" "org" {
  name = var.config_aggregator_name
  organization_aggregation_source {
    all_regions = true
    role_arn    = aws_iam_role.config_aggregator.arn
  }
}

########################
# GuardDuty（Delegated Admin アカウントで実行）
########################
resource "aws_guardduty_detector" "this" {
  enable = true
  tags   = var.tags
}

# すべての組織メンバーを自動有効化
resource "aws_guardduty_organization_configuration" "this" {
  detector_id                         = aws_guardduty_detector.this.id
  auto_enable_organization_members    = "ALL"
}

########################
# Security Hub（Delegated Admin アカウントで実行）
########################
# Enable Security Hub in this account
resource "aws_securityhub_account" "this" {}

# Auto-enable for new org accounts
resource "aws_securityhub_organization_configuration" "this" {
  auto_enable = true
}

# Subscribe to AWS Foundational Security Best Practices
resource "aws_securityhub_standards_subscription" "afsbp" {
  standards_arn = "arn:aws:securityhub:::standards/aws-foundational-security-best-practices/v/1.0.0"
}

########################
# Security Hub Finding Aggregator
########################
resource "aws_securityhub_finding_aggregator" "this" {
  linking_mode = "ALL_REGIONS"
}
