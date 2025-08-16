locals {
  common_tags = {
    Environment = var.env
    Application = var.app_name
    ManagedBy   = "Terraform"
    Region      = var.region
  }
}