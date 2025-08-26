output "root_id" {
  value = local.root_id
}

output "ou_ids" {
  value = { for k, v in aws_organizations_organizational_unit.ou : k => v.id }
}

output "account_ids" {
  value = { for k, v in aws_organizations_account.acct : k => v.id }
}
