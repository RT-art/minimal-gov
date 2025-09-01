import {
  to = aws_cloudtrail_organization_delegated_admin_account.this
  id = "454842420215" 
}

# org 側 state の参照（org 側の bucket/key/region に合わせて）
data "terraform_remote_state" "org" {
  backend = "s3"
  config = {
    bucket = "aws-remotebackend-bootstrap-tfstate-ap-northeast-1-653502182074"
    key    = "state/organization/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

locals {
  security_account_id = data.terraform_remote_state.org.outputs.security_account_id
}

# GuardDuty 管理者登録（管理アカウントで実行）
resource "aws_guardduty_organization_admin_account" "tokyo" {
  provider         = aws.tokyo
  admin_account_id = local.security_account_id
}

# Security Hub 管理者登録（管理アカウントで実行）
resource "aws_securityhub_organization_admin_account" "tokyo" {
  provider         = aws.tokyo
  admin_account_id = local.security_account_id
}

# CloudTrail 委任（グローバル扱い・1回）
resource "aws_cloudtrail_organization_delegated_admin_account" "this" {
  provider   = aws.tokyo
  account_id = local.security_account_id
}
