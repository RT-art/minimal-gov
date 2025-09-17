generate "provider" {
  path      = "_provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF2
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
EOF2
}

remote_state {
  backend = "s3"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }

  config = {
    bucket       = "aws-remotebackend-bootstrap-tfstate-ap-northeast-1-653502182074"
    key          = "state/organization/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true
  }
}

inputs = {
  # Metadata
  env      = "prod"
  app_name = "minimal-gov-org"
  region   = "ap-northeast-1"
  tags = {
    Project     = "minimal-gov"
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
