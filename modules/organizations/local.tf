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


  # Root OU map: key = lowercase name, value = display name
  ou_root = { for n in var.ou_root : lower(n) => n }

  # Nested OU map: key = lowercase child name, value = object(name, parent)
  ou_nested = merge([
    for parent, children in var.ou_children : {
      for c in children : lower(c) => {
        name   = c
        parent = lower(parent)
      }
    }
  ]...)

  org_root_id = aws_organizations_organization.this.roots[0].id

  ou_ids = merge(
    { for k, v in aws_organizations_organizational_unit.ou_root : k => v.id },
    { for k, v in aws_organizations_organizational_unit.ou_nested : k => v.id }
  )
}
