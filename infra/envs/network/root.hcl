locals {
  common = read_terragrunt_config(find_in_parent_folders("_common.hcl"))
}

generate "provider" {
  path      = "_provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Application = var.app_name
      Environment = var.env
      ManagedBy   = "Terraform"
      Region      = var.region
    }
  }
}
EOF
}

generate "versions" {
  path      = "_versions.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = "${local.common.locals.versions.terraform}"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "${local.common.locals.versions.aws}"
    }
  }
}
EOF
}

remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    bucket  = "minimal-gov-network-backend-tfstate-ap-northeast-1-854669817093"
    key     = "${path_relative_to_include()}/terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
  }
}

inputs = {
  # Metadata
  env      = "prod"
  app_name = "minimal-gov-network"
  region   = "ap-northeast-1"
  tags = {
    Project     = "minimal-gov"
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}
