output "security_account_id" {
  value = aws_organizations_account.security.id
}

output "ou_ids" {
  description = "OU IDs keyed by logical name"
  value       = local.ou_ids
}

output "scp_policy_ids" {
  value = module.scp.policy_ids
}

output "member_account_ids" {
  value = { for k, v in aws_organizations_account.members : k => v.id }
}

