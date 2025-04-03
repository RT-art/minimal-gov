locals {
  common_tags = {
    Environment = var.env      # var.env は variables.tf で定義されている想定
    Application = var.app_name # var.app_name も variables.tf で定義されている想定
    ManagedBy   = "Terraform"
    Region      = var.region # var.region も variables.tf で定義されている想定
  }
}