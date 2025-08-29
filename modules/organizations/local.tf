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

  ous = {
    security  = { name = "Security", parent = "root" }
    workloads = { name = "Workloads", parent = "root" }
    prod      = { name = "Prod", parent = "workloads" }
    dev       = { name = "Dev", parent = "workloads" }
    sandbox   = { name = "Sandbox", parent = "root" }
    suspended = { name = "Suspended", parent = "root" }
  }

  org_root_id = aws_organizations_organization.this.roots[0].id
}
