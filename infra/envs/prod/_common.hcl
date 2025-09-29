locals {
  inputs = {
    env    = "prod"
    region = "ap-northeast-1"
    tags = {
      Project     = "minimal-gov"
      Environment = "prod"
      ManagedBy   = "Terraform"
      AccountId   = get_aws_account_id()
    }
  }
}
