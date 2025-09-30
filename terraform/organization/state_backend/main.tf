module "terraform_remote_backend" {
  source              = "../../modules/storage/backend"
  env                 = var.env
  app_name            = var.app_name
  region              = var.region
  tags                = var.tags
  versioning_enabled  = var.versioning_enabled
  use_kms             = var.use_kms
  kms_master_key_id   = var.kms_master_key_id
  force_destroy       = var.force_destroy
  lifecycle_days      = var.lifecycle_days
  allowed_account_ids = var.allowed_account_ids
}
