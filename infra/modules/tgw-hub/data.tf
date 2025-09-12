data "terraform_remote_state" "tgw" {
  backend = "s3"
  config = {
    bucket = var.tgw_state.bucket
    key    = var.tgw_state.key
    region = var.tgw_state.region
  }
}

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.vpc_state.bucket
    key    = var.vpc_state.key
    region = var.vpc_state.region
  }
}