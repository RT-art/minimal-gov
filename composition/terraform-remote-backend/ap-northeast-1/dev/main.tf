########################################
# AWS Terraform backend composition
########################################

data "aws_caller_identity" "current" {}

module "terraform_remote_backend" {
  source = "../../../../infrastructure_modules/remotebackend"

  env      = var.env
  app_name = var.app_name
  region   = var.region

  #s3 bucket
  versioning_enabled                   = var.versioning_enabled
  server_side_encryption_configuration = var.server_side_encryption_configuration
  control_object_ownership             = var.control_object_ownership
  aws_account_id                       = data.aws_caller_identity.current.account_id
}
