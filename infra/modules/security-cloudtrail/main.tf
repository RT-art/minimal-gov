###############################################
# Minimal Gov: Security CloudTrail module
#
# This module provisions the resources required for an
# organization-wide CloudTrail setup. It creates a secure S3
# bucket to aggregate audit logs and an Organization Trail that
# delivers logs to that bucket.
#
# Resources created:
# - S3 bucket with security best practices (versioning,
#   encryption, public access block, ownership controls)
# - Bucket policy permitting CloudTrail service to write logs
# - Organization-level CloudTrail trail
#
# Design guidelines:
# - Keep logic straightforward and heavily documented
# - Enable secure defaults (encryption, public access block)
# - Expose only necessary outputs for upstream dependencies
###############################################

data "aws_caller_identity" "current" {}

locals {
  # Determine the bucket name. If bucket_name is provided, use it;
  # otherwise generate a name based on account ID and region to
  # ensure global uniqueness.
  bucket_name = var.bucket_name != null && var.bucket_name != "" ? var.bucket_name : "ct-logs-${data.aws_caller_identity.current.account_id}-${var.region}"
}

###############################################
# S3 bucket for CloudTrail logs
###############################################
resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name
}

# Enforce bucket owner preferred to avoid object ownership issues
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Block all public access to the bucket for security
resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning so that log files are immutable and can be recovered
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable server-side encryption (SSE-S3 or SSE-KMS depending on use_kms)
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.use_kms ? "aws:kms" : "AES256"
      kms_master_key_id = var.use_kms ? var.kms_key_id : null
    }
  }
}

###############################################
# Bucket policy: allow CloudTrail to write logs
###############################################
data "aws_iam_policy_document" "bucket" {
  statement {
    sid    = "AWSCloudTrailAclCheck"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.this.arn]
  }

  statement {
    sid    = "AWSCloudTrailWrite"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    actions = ["s3:PutObject"]
    # Allow CloudTrail to write logs for all accounts in the Organization
    # under the AWSLogs/ prefix.
    resources = ["${aws_s3_bucket.this.arn}/AWSLogs/*"]
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.bucket.json
}

###############################################
# Organization-wide CloudTrail trail
###############################################
resource "aws_cloudtrail" "this" {
  name                          = var.trail_name
  s3_bucket_name                = aws_s3_bucket.this.bucket
  kms_key_id                    = var.use_kms ? var.kms_key_id : null
  is_organization_trail         = true
  enable_logging                = var.enable_logging
  enable_log_file_validation    = true
  include_global_service_events = true
  is_multi_region_trail         = true
  depends_on                    = [aws_s3_bucket_policy.this]
  tags                          = var.tags
}

