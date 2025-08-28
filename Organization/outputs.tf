output "security_account_id" {
  value       = module.organizations.security_account_id
  description = "作成されたSecurityアカウントID"
}

output "organizational_units" {
  value       = module.organizations.ou_ids
  description = "主要OUのIDマップ"
}

output "scp_policy_ids" {
  value       = module.organizations.scp_policy_ids
  description = "作成されたSCPのID"
}
