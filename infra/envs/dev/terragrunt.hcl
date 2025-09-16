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

remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    bucket       = "minimal-gov-network-tfstate-ap-northeast-1-351277498040"
    key          = "${path_relative_to_include()}/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
  }
}
