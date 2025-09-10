# modules/organizations/outputs.tf

// このモジュールが作成した Organization/OU/アカウントの識別子をまとめて出力します。
// 下流モジュールや別スタックから参照できるように、よく使う値を厳選して公開しています。

// Organization 本体の ID（例: o-xxxxxxxxxx）
output "organization_id" {
  description = "AWS Organization の ID"
  value       = aws_organizations_organization.this.id
}

// ルート（Root OU）の ID（例: r-xxxx）
output "root_id" {
  description = "Organization ルート（Root）の ID"
  value       = local.root_id
}

// セキュリティアカウント（Security OU 配下に作成した管理用アカウント）の ID
output "security_account_id" {
  description = "Security アカウントの AWS Account ID"
  value       = aws_organizations_account.security.id
}

// メンバーアカウントの ID 一覧
// key は variable "member_accounts" のキー（任意に定義した論理名）、value は実アカウント ID
output "member_account_ids" {
  description = "メンバーアカウントの ID マップ (key: 論理名, value: Account ID)"
  value       = { for k, v in aws_organizations_account.members : k => v.id }
}

// 主要 OU と追加 OU の ID 一覧
// 主要 OU: security, workloads, prod, dev, sandbox, suspended（すべて lower-case キー）
// 追加 OU: variable "additional_ous" のキーを lower-case に正規化して格納
output "ou_ids" {
  description = "主要 OU と追加 OU の ID マップ"
  value = merge(
    local.ou_ids,
    { for k, ou in aws_organizations_organizational_unit.additional_ou : lower(k) => ou.id }
  )
}
