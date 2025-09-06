# Organization/outputs.tf

// このスタック全体でよく参照する値を出力します。
// modules/organizations で作成された各種 ID を、下流から参照しやすい形にまとめています。

// Organization 本体の ID（例: o-xxxxxxxxxx）
output "organization_id" {
  description = "AWS Organization の ID"
  value       = module.organizations.organization_id
}

// ルート（Root）の ID（例: r-xxxx）
output "root_id" {
  description = "Organization ルート（Root）の ID"
  value       = module.organizations.root_id
}

// セキュリティアカウントの AWS アカウント ID
output "security_account_id" {
  description = "Security アカウントの AWS Account ID"
  value       = module.organizations.security_account_id
}

// メンバーアカウントの ID 一覧
// key は variable "member_accounts" のキー（任意に定義した論理名）、value は実アカウント ID
output "member_account_ids" {
  description = "メンバーアカウントの ID マップ (key: 論理名, value: Account ID)"
  value       = module.organizations.member_account_ids
}

// 主要 OU と追加 OU の ID 一覧
// 主要 OU キーは lower-case（security, workloads, prod, dev, sandbox, suspended）
// 例) module.organizations.ou_ids["security"] で Security OU の ID を参照可能
output "ou_ids" {
  description = "主要 OU と追加 OU の ID マップ"
  value       = module.organizations.ou_ids
}
