locals {
  inputs = {
    env      = "dev"
    region   = "ap-northeast-1"
    tags = {
      Project     = "minimal-gov"
      Environment = "dev"
      ManagedBy   = "Terraform"
    }
  }
}
