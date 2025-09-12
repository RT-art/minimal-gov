module "config" {
  source                      = "../../../../modules/security-config"
  env                         = var.env
  app_name                    = var.app_name
  region                      = var.region
  bucket_name                 = var.bucket_name
  create_bucket               = var.create_bucket
  aggregator_role_name        = var.aggregator_role_name
  snapshot_delivery_frequency = var.snapshot_delivery_frequency
  tags                        = var.tags
}
