data "aws_organizations_organization" "current" {
  count = var.manage_organization ? 0 : 1
}

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
  delegate_targets = setintersection(local.aws_service_access_principals, var.delegated_admin_allowlist)

  root_id = aws_organizations_organization.this.roots[0].id

  really_close = var.close_account_on_destroy && var.close_account_confirmation == "I_UNDERSTAND"

  ous = {
    security  = { name = "Security", parent = "root" }
    workloads = { name = "Workloads", parent = "root" }
    prod      = { name = "Prod", parent = "workloads" }
    dev       = { name = "Dev", parent = "workloads" }
    sandbox   = { name = "Sandbox", parent = "root" }
    suspended = { name = "Suspended", parent = "root" }
  }

  org_root_id = var.manage_organization ? aws_organizations_organization.this[0].roots[0].id : data.aws_organizations_organization.current[0].roots[0].id
}
