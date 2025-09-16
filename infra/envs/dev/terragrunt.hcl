generate "provider" {
  path      = "_provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "ap-northeast-1"

  default_tags {
    tags = {
      Application = "workload"
      Environment = "dev"
      ManagedBy   = "Terraform"
      Region      = "ap-northeast-1"
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
    bucket       = "minimal-gov-network-backend-tfstate-ap-northeast-1-854669817093"
    key          = "${path_relative_to_include()}/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
  }
}
