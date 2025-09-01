resource "aws_organizations_organization" "this" {
  feature_set                   = "ALL"
  enabled_policy_types          = tolist(var.enabled_policy_types)    # なんのポリシーを有効化するか
  aws_service_access_principals = local.aws_service_access_principals # サービスアクセスを有効化するリソース指定

  # Organizations の削除は必ず手動
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

resource "aws_organizations_organizational_unit" "ou_root" {
  for_each  = local.ou_root
  name      = each.value
  parent_id = local.org_root_id
  tags      = var.tags

  lifecycle { prevent_destroy = true }
}

resource "aws_organizations_organizational_unit" "ou_nested" {
  for_each  = local.ou_nested
  name      = each.value
  parent_id = aws_organizations_organizational_unit.ou_root["workloads"].id
  tags      = var.tags

  lifecycle { prevent_destroy = true }
}

resource "aws_organizations_account" "security" {
  name      = var.security_account_name
  email     = var.security_account_email
  role_name = var.org_admin_role_name
  # セキュリティOUのidを指定
  parent_id = local.ou_ids["security"]
  tags      = merge(var.tags, { AccountType = "Security" })

  lifecycle {
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
  # 入力のOU名とfor_eachのkeyを確実に合わせるため、少し冗長だがlookupで取得
  # 指定がなければSandboxに入れる
  parent_id = lookup({
    "Security"       = local.ou_ids["security"]
    "Workloads"      = local.ou_ids["workloads"]
    "Workloads/Prod" = local.ou_ids["prod"]
    "Workloads/Dev"  = local.ou_ids["dev"]
    "Sandbox"        = local.ou_ids["sandbox"]
    "Suspended"      = local.ou_ids["suspended"]
  }, each.value.ou, local.ou_ids["sandbox"])

  tags = merge(var.tags, { AccountType = "Member" })

  lifecycle {
    prevent_destroy = true
  }

  timeouts {
    create = "2h"
  }
}

# Securityアカウントを委任管理者に登録
# guardduty, config, cloudtrail, securityhub は Organizations 作成時に自動登録
# 追加で登録したいサービスがあれば変数で指定
resource "aws_organizations_delegated_administrator" "security_delegate" {
  for_each          = local.delegate_targets
  account_id        = aws_organizations_account.security.id
  service_principal = each.value
  depends_on        = [aws_organizations_account.security, aws_organizations_organization.this]
}

module "scp" {
  source = "../scp"

  allowed_regions = var.allowed_regions
  tags            = var.tags

  targets = {
    root_id     = local.org_root_id
    security_ou = local.ou_ids["security"]
    workloads   = local.ou_ids["workloads"]
    prod        = local.ou_ids["prod"]
    dev         = local.ou_ids["dev"]
    sandbox     = local.ou_ids["sandbox"]
    suspended   = local.ou_ids["suspended"]
  }

  attach_map = {
    deny_root                 = ["root_id"]
    deny_leaving_org          = ["root_id"]
    deny_unapproved_regions   = ["root_id"]
    deny_disable_sec_services = ["prod", "dev", "sandbox"]
    deny_all_suspended        = ["suspended"]
  }

  depends_on = [aws_organizations_organization.this]
}
