locals {
  s3_bucket_name_raw = lower(replace("${var.app_name}-tfstate-${var.region}-${var.aws_account_id}", "_", "-"))
  s3_bucket_name_63  = substr(local.s3_bucket_name_raw, 0, 63)
  s3_bucket_name     = trim(local.s3_bucket_name_63, "-.")
}