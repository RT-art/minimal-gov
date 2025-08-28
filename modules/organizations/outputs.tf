output "security_account_id" {
  value = aws_organizations_account.security.id
}

output "ou_ids" {
  value = {
    root_id   = local.root_id
    security  = aws_organizations_organizational_unit.security.id
    workloads = aws_organizations_organizational_unit.workloads.id
    prod      = aws_organizations_organizational_unit.prod.id
    dev       = aws_organizations_organizational_unit.dev.id
    sandbox   = aws_organizations_organizational_unit.sandbox.id
    suspended = aws_organizations_organizational_unit.suspended.id
  }
}

output "scp_policy_ids" {
  value = module.scp.policy_ids
}

output "member_account_ids" {
  value = { for k, v in aws_organizations_account.members : k => v.id }
}

