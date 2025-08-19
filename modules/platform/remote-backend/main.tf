data "aws_caller_identity" "current" {}

module "state_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.4.0" # 2025年8月の最新バージョン

  bucket                = local.s3_bucket_name
  versioning            = local.versioning
  expected_bucket_owner = local.account_id

  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"

  force_destroy = var.force_destroy
  tags          = var.tags

  block_public_acls                      = true
  block_public_policy                    = true
  ignore_public_acls                     = true
  restrict_public_buckets                = true
  attach_require_latest_tls_policy       = true
  attach_deny_unencrypted_object_uploads = true
  attach_deny_insecure_transport_policy  = true

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = var.use_kms ? "aws:kms" : "AES256"
        kms_master_key_id = var.use_kms ? var.kms_master_key_id : null
      }
      bucket_key_enabled = var.use_kms
    }
  }

  lifecycle_rule = [{
    id      = "noncurrent-cleanup"
    enabled = true
    noncurrent_version_expiration = {
      days = var.lifecycle_days
    }
  }]

}
