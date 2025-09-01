# Organization/outputs.tf

output "ou_ids" {
  value = module.organizations.ou_ids
}
output "all_account_ids" {
  value = merge(
    { security = module.organizations.security_account_id },
    module.organizations.member_account_ids
  )
}
