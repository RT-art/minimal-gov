locals {
  # 管理するポリシーIDをわかりやすくまとめる
  policies = {
    deny_root                 = aws_organizations_policy.deny_root.id
    deny_leaving_org          = aws_organizations_policy.deny_leaving_org.id
    deny_unapproved_regions   = aws_organizations_policy.deny_unapproved_regions.id
    deny_disable_sec_services = aws_organizations_policy.deny_disable_sec_services.id
    deny_all_suspended        = aws_organizations_policy.deny_all_suspended.id
  }

  # ポリシーとターゲットの対応表をシンプルに記述
  attach_map = {
    deny_root                 = [var.account_root]
    deny_leaving_org          = [var.org_id]
    deny_unapproved_regions   = var.security_accounts
    deny_disable_sec_services = var.security_accounts
    deny_all_suspended        = var.suspended_accounts
  }
}