########################################
# AWS Terraform backend composition
########################################

data "aws_caller_identity" "current" {}

module "terraform_remote_backend" {
  source = "../../../../infrastructure_modules/remotebackend" # 作成したRemoteBackend用Infraモジュールのパス

  env      = var.env
  app_name = var.app_name
  region   = var.region
  tags     = local.tags

  #s3 bucket
  versioning_enabled                   = var.versioning_enabled
  server_side_encryption_configuration = var.server_side_encryption_configuration
  control_object_ownership             = var.control_object_ownership
  aws_account_id = data.aws_caller_identity.current.account_id

  #dynamodb table
  hash_key                       = var.hash_key
  server_side_encryption_enabled = var.server_side_encryption_enabled
  point_in_time_recovery_enabled = var.point_in_time_recovery_enabled
  create_table                   = var.create_table
  ttl_enabled                    = var.ttl_enabled
  stream_enabled                 = var.stream_enabled
  autoscaling_enabled            = var.autoscaling_enabled
}