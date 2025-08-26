module "org_bootstrap" {
  source          = "./modules/organizations"
  ous             = var.ous
  accounts        = var.accounts
  allowed_regions = var.allowed_regions
  default_tags    = var.default_tags
}
