module "ecr" {
  source              = "../../../../modules/ecr-repository"
  env                 = var.env
  app_name            = var.app_name
  region              = var.region
  name                = var.name
  keep_last_images    = var.keep_last_images
  kms_key_arn         = var.kms_key_arn
  pull_principal_arns = var.pull_principal_arns
  tags                = var.tags
}
