module "organizations" {
  source = "./modules/organizations"

  org_name_prefix        = var.org_name_prefix
  security_account_name  = var.security_account_name
  security_account_email = var.security_account_email
  org_admin_role_name    = var.org_admin_role_name
  allowed_regions        = var.allowed_regions
  member_accounts        = var.member_accounts
  tags                   = var.tags

  # 将来 Security を各種サービスの委任管理者にする時に使う（今は空のままでOK）
  delegate_admin_for = [] # 例: ["guardduty.amazonaws.com","config.amazonaws.com","securityhub.amazonaws.com"]
}
