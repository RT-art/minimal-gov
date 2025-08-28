locals {
  aws_service_access_principals = setunion(
    [
      "guardduty.amazonaws.com",
      "config.amazonaws.com",
      "cloudtrail.amazonaws.com",
      "securityhub.amazonaws.com"
    ],
    var.delegate_admin_for
  )
  root_id      = aws_organizations_organization.this.roots[0].id
  really_close = var.close_account_on_destroy && var.close_account_confirmation == "I_UNDERSTAND"
}

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

resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = local.root_id
  tags      = var.tags
}

resource "aws_organizations_organizational_unit" "workloads" {
  name      = "Workloads"
  parent_id = local.root_id
  tags      = var.tags
}

resource "aws_organizations_organizational_unit" "prod" {
  name      = "Prod"
  parent_id = aws_organizations_organizational_unit.workloads.id
  tags      = var.tags
}

resource "aws_organizations_organizational_unit" "dev" {
  name      = "Dev"
  parent_id = aws_organizations_organizational_unit.workloads.id
  tags      = var.tags
}

resource "aws_organizations_organizational_unit" "sandbox" {
  name      = "Sandbox"
  parent_id = local.root_id
  tags      = var.tags
}

resource "aws_organizations_organizational_unit" "suspended" {
  name      = "Suspended"
  parent_id = local.root_id
  tags      = var.tags
}

resource "aws_organizations_account" "security" {
  name      = var.security_account_name
  email     = var.security_account_email
  role_name = var.org_admin_role_name
  parent_id = aws_organizations_organizational_unit.security.id
  tags      = merge(var.tags, { AccountType = "Security" })

  lifecycle {
    ignore_changes = var.lock_account_name ? [name] : []

    precondition {
      condition     = !(var.close_account_on_destroy) || local.really_close
      error_message = "アカウントを閉鎖するには close_account_confirmation に 'I_UNDERSTAND' を指定してください。"
    }
  }

  timeouts {
    create = "2h"
    delete = "2h"
  }
}

resource "aws_organizations_account" "members" {
  for_each  = var.member_accounts
  name      = each.name
  email     = each.value.email
  role_name = var.org_admin_role_name
  parent_id = lookup({
    "Security"       = aws_organizations_organizational_unit.security.id,
    "Workloads"      = aws_organizations_organizational_unit.workloads.id,
    "Workloads/Prod" = aws_organizations_organizational_unit.prod.id,
    "Workloads/Dev"  = aws_organizations_organizational_unit.dev.id,
    "Sandbox"        = aws_organizations_organizational_unit.sandbox.id,
    "Suspended"      = aws_organizations_organizational_unit.suspended.id
  }, each.value.ou, aws_organizations_organizational_unit.sandbox.id)

  tags = merge(var.tags, { AccountType = "Member" })

  lifecycle {
    ignore_changes = var.lock_account_name ? [name] : []

    precondition {
      condition     = !(var.close_account_on_destroy) || local.really_close
      error_message = "アカウントを閉鎖するには close_account_confirmation に 'I_UNDERSTAND' を指定してください。"
    }
  }

  timeouts {
    create = "2h"
    delete = "2h"
  }
}

resource "aws_organizations_delegated_administrator" "security_delegate" {
  for_each = local.aws_service_access_principals

  account_id        = aws_organizations_account.security.id
  service_principal = each.value

  depends_on = [aws_organizations_account.security, aws_organizations_organization.this]
}

module "scp" {
  source = "../scp"

  allowed_regions = var.allowed_regions
  tags            = var.tags

  targets = {
    root_id     = local.root_id
    security_ou = aws_organizations_organizational_unit.security.id
    workloads   = aws_organizations_organizational_unit.workloads.id
    prod        = aws_organizations_organizational_unit.prod.id
    dev         = aws_organizations_organizational_unit.dev.id
    sandbox     = aws_organizations_organizational_unit.sandbox.id
    suspended   = aws_organizations_organizational_unit.suspended.id
  }

  attach_map = {
    deny_root                 = ["root_id"]
    deny_leaving_org          = ["root_id"]
    deny_unapproved_regions   = ["root_id"]
    deny_disable_sec_services = ["prod", "dev", "sandbox"]
  }
}
