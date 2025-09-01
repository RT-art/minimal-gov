# modules/organizations/outputs.tf

output "ou_ids" {
  value = local.ou_ids
}

output "security_account_id" {
  value = aws_organizations_account.security.id
}

output "member_account_ids" {
  value = { for k, v in aws_organizations_account.members : k => v.id }
}
