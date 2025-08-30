output "security_account_id" {
  description = "Security アカウントの ID"
  value       = module.organizations.security_account_id
}

output "ou_ids" {
  description = "作成された OU の ID 一覧"
  value       = module.organizations.ou_ids
}

output "scp_policy_ids" {
  description = "作成された SCP の ID 一覧"
  value       = module.organizations.scp_policy_ids
}

output "member_account_ids" {
  description = "作成されたメンバーアカウントの ID マップ"
  value       = module.organizations.member_account_ids
}
