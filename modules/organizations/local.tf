locals {
  aws_service_access_principals = setunion(
    toset([
      "guardduty.amazonaws.com",
      "config.amazonaws.com",
      "cloudtrail.amazonaws.com",
      "securityhub.amazonaws.com"
    ]),
    var.delegate_admin_for
  )

  delegate_targets = setintersection(var.delegate_admin_for, var.delegated_admin_allowlist)


  ou_root = {
    security  = "Security"
    workloads = "Workloads"
    sandbox   = "Sandbox"
    suspended = "Suspended"
  }
  ou_nested = {
    prod = "Prod"
    dev  = "Dev"
  }

  org_root_id = aws_organizations_organization.this.roots[0].id

  ou_ids = merge(
    { for k, v in aws_organizations_organizational_unit.ou_root : k => v.id },
    { for k, v in aws_organizations_organizational_unit.ou_nested : k => v.id }
  )
}
