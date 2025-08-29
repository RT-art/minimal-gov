resource "aws_organizations_organization" "this" {
  feature_set                   = "ALL"
  enabled_policy_types          = tolist(var.enabled_policy_types)
  aws_service_access_principals = local.aws_service_access_principals

  lifecycle {
    prevent_destroy = true
  }
}

# Root
# ├─ Security
# ├─ Workloads
# │   ├─ Prod
# │   └─ Dev
# ├─ Sandbox
# └─ Suspended

resource "aws_organizations_organizational_unit" "ou" {
  for_each  = local.ous
  name      = each.value.name
  parent_id = each.value.parent == "root" ? local.org_root_id : aws_organizations_organizational_unit.ou[each.value.parent].id
  tags      = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_organizations_account" "security" {
  name      = var.security_account_name
  email     = var.security_account_email
  role_name = var.org_admin_role_name
  parent_id = aws_organizations_organizational_unit.ou["security"].id
  tags      = merge(var.tags, { AccountType = "Security" })

  lifecycle {
    ignore_changes  = var.lock_account_name ? [name] : []
    prevent_destroy = true
  }

  timeouts {
    create = "2h"
  }
}

resource "aws_organizations_account" "members" {
  for_each  = var.member_accounts
  name      = each.value.name
  email     = each.value.email
  role_name = var.org_admin_role_name
  parent_id = lookup({
    "Security"       = aws_organizations_organizational_unit.ou["security"].id
    "Workloads"      = aws_organizations_organizational_unit.ou["workloads"].id
    "Workloads/Prod" = aws_organizations_organizational_unit.ou["prod"].id
    "Workloads/Dev"  = aws_organizations_organizational_unit.ou["dev"].id
    "Sandbox"        = aws_organizations_organizational_unit.ou["sandbox"].id
    "Suspended"      = aws_organizations_organizational_unit.ou["suspended"].id
  }, each.value.ou, aws_organizations_organizational_unit.ou["sandbox"].id)

  tags = merge(var.tags, { AccountType = "Member" })

  lifecycle {
    ignore_changes  = var.lock_account_name ? [name] : []
    prevent_destroy = true
  }

  timeouts {
    create = "2h"
  }
}

resource "aws_organizations_delegated_administrator" "security_delegate" {
  for_each          = local.delegate_targets
  account_id        = aws_organizations_account.security.id
  service_principal = each.value
  depends_on        = [aws_organizations_account.security,aws_organizations_organization.this]
}

module "scp" {
  source = "../scp"

  allowed_regions = var.allowed_regions
  tags            = var.tags

  targets = {
    root_id     = local.org_root_id
    security_ou = aws_organizations_organizational_unit.ou["security"].id
    workloads   = aws_organizations_organizational_unit.ou["workloads"].id
    prod        = aws_organizations_organizational_unit.ou["prod"].id
    dev         = aws_organizations_organizational_unit.ou["dev"].id
    sandbox     = aws_organizations_organizational_unit.ou["sandbox"].id
    suspended   = aws_organizations_organizational_unit.ou["suspended"].id
  }

  attach_map = {
    deny_root                 = ["root_id"]
    deny_leaving_org          = ["root_id"]
    deny_unapproved_regions   = ["root_id"]
    deny_disable_sec_services = ["prod", "dev", "sandbox"]
    deny_all_suspended        = ["suspended"]
  }
}
