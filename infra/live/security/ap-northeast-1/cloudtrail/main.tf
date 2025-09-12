module "cloudtrail" {
  source         = "../../../../modules/security-cloudtrail"
  trail_name     = var.trail_name
  bucket_name    = var.bucket_name
  region         = var.region
  use_kms        = var.use_kms
  kms_key_id     = var.kms_key_id
  enable_logging = var.enable_logging
  tags           = var.tags
}
