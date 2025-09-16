include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/oidc"
}

inputs = {
# Metadata
env      = "dev"
app_name = "minimal-gov-network"
region   = "ap-northeast-1"
tags = {
  Project     = "minimal-gov"
  Environment = "dev"
  ManagedBy   = "Terraform"
}
# OIDC
github_org  = "RT-art"
github_repo = "minimal-gov"
}
