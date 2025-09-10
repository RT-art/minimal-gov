data "terraform_remote_state" "org" {
  backend = "s3"
  config = {
    bucket = var.org_state_bucket
    key    = var.org_state_key
    region = var.org_state_region
  }
}

locals {
  security_account_id = data.terraform_remote_state.org.outputs.security_account_id
}

# GuardDuty 管理者登録
resource "aws_guardduty_organization_admin_account" "tokyo" {
  admin_account_id = local.security_account_id
}

# Security Hub 管理者登録
resource "aws_securityhub_organization_admin_account" "tokyo" {
  admin_account_id = local.security_account_id
}

# CloudTrail 委任
resource "aws_cloudtrail_organization_delegated_admin_account" "this" {
  account_id = local.security_account_id
}
