output "security_account_id" {
  value = aws_organizations_account.security.id
}

output "ou_ids" {
  value = {
    root_id   = local.org_root_id
    security  = aws_organizations_organizational_unit.ou["security"].id
    workloads = aws_organizations_organizational_unit.ou["workloads"].id
    prod      = aws_organizations_organizational_unit.ou["prod"].id
    dev       = aws_organizations_organizational_unit.ou["dev"].id
    sandbox   = aws_organizations_organizational_unit.ou["sandbox"].id
    suspended = aws_organizations_organizational_unit.ou["suspended"].id
  }
}

output "scp_policy_ids" {
  value = module.scp.policy_ids
}

output "member_account_ids" {
  value = { for k, v in aws_organizations_account.members : k => v.id }
}

