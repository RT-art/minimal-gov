locals {
  name_prefix = var.org_name_prefix
  tags        = var.tags
}

# Organizations 本体
resource "aws_organizations_organization" "this" {
  feature_set = "ALL"

  enabled_policy_types = [
    "SERVICE_CONTROL_POLICY",
    # 必要なら "TAG_POLICY", "BACKUP_POLICY"
  ]

  # 将来の委任に備え、組織へのサービスアクセスを許可（必要になったら増やす）
  aws_service_access_principals = distinct(concat(
    [
      "guardduty.amazonaws.com",
      "config.amazonaws.com",
      "cloudtrail.amazonaws.com",
      "securityhub.amazonaws.com"
    ],
    var.delegate_admin_for
  ))
}

# ルートID
locals {
  root_id = aws_organizations_organization.this.roots[0].id
}

# OU 構成（ベストプラクティスのたたき台）
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
  tags      = local.tags
}

resource "aws_organizations_organizational_unit" "workloads" {
  name      = "Workloads"
  parent_id = local.root_id
  tags      = local.tags
}

resource "aws_organizations_organizational_unit" "prod" {
  name      = "Prod"
  parent_id = aws_organizations_organizational_unit.workloads.id
  tags      = local.tags
}

resource "aws_organizations_organizational_unit" "dev" {
  name      = "Dev"
  parent_id = aws_organizations_organizational_unit.workloads.id
  tags      = local.tags
}

resource "aws_organizations_organizational_unit" "sandbox" {
  name      = "Sandbox"
  parent_id = local.root_id
  tags      = local.tags
}

resource "aws_organizations_organizational_unit" "suspended" {
  name      = "Suspended"
  parent_id = local.root_id
  tags      = local.tags
}

# Security アカウント作成（最初に作る）
resource "aws_organizations_account" "security" {
  name      = var.security_account_name
  email     = var.security_account_email
  role_name = var.org_admin_role_name
  tags      = merge(local.tags, { AccountType = "Security" })
}

# Root -> Security OU へ移動
resource "aws_organizations_move_account" "security_to_ou" {
  account_id        = aws_organizations_account.security.id
  source_parent_id  = local.root_id
  destination_parent_id = aws_organizations_organizational_unit.security.id
}

# 将来のメンバーアカウント（あとから var.member_accounts に追記でOK）
resource "aws_organizations_account" "members" {
  for_each  = var.member_accounts
  name      = each.key
  email     = each.value.email
  role_name = var.org_admin_role_name
  tags      = merge(local.tags, { AccountType = "Member" })
}

# アカウントを指定OUへ移動
resource "aws_organizations_move_account" "members_to_ou" {
  for_each = var.member_accounts

  account_id       = aws_organizations_account.members[each.key].id
  source_parent_id = local.root_id
  destination_parent_id = lookup({
    "Security"        = aws_organizations_organizational_unit.security.id,
    "Workloads"       = aws_organizations_organizational_unit.workloads.id,
    "Workloads/Prod"  = aws_organizations_organizational_unit.prod.id,
    "Workloads/Dev"   = aws_organizations_organizational_unit.dev.id,
    "Sandbox"         = aws_organizations_organizational_unit.sandbox.id,
    "Suspended"       = aws_organizations_organizational_unit.suspended.id
  }, each.value.ou, aws_organizations_organizational_unit.sandbox.id)
}

# （任意）Security を各サービスの委任管理者にする
resource "aws_organizations_delegated_administrator" "security_delegate" {
  for_each = toset(var.delegate_admin_for)

  account_id        = aws_organizations_account.security.id
  service_principal = each.value

  depends_on = [aws_organizations_move_account.security_to_ou]
}

# ベースSCPを作成・アタッチ
module "scp" {
  source = "../scp"

  allowed_regions = var.allowed_regions
  tags            = local.tags

  targets = {
    root_id     = local.root_id
    security_ou = aws_organizations_organizational_unit.security.id
    workloads   = aws_organizations_organizational_unit.workloads.id
    prod        = aws_organizations_organizational_unit.prod.id
    dev         = aws_organizations_organizational_unit.dev.id
    sandbox     = aws_organizations_organizational_unit.sandbox.id
    suspended   = aws_organizations_organizational_unit.suspended.id
  }

  # 方針：
  # - ルート：root全体に「rootユーザ禁止」「組織離脱禁止」「未承認リージョン禁止」
  # - Workloads系（Prod/Dev/Sandbox）：セキュリティサービス無効化の禁止
  attach_map = {
    deny_root                  = ["root_id"]
    deny_leaving_org           = ["root_id"]
    deny_unapproved_regions    = ["root_id"]
    deny_disable_sec_services  = ["prod", "dev", "sandbox"]
  }
}
