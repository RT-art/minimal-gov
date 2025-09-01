module "organizations" {
  source = "../modules/organizations"

  security_account_email = var.security_account_email
  allowed_regions        = var.allowed_regions
  tags                   = var.tags

  # 任意（モジュールのデフォルトを上書きしたい時だけ指定）
  security_account_name = var.security_account_name
  org_admin_role_name   = var.org_admin_role_name
  delegate_admin_for    = var.delegate_admin_for
  enabled_policy_types  = var.enabled_policy_types
  member_accounts       = var.member_accounts

  # delegated_admin_allowlist はモジュールで既定値あり。上書きしたい場合のみ渡してください。
  # delegated_admin_allowlist = var.delegated_admin_allowlist
}
