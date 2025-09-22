# scp module
# ベースラインSCPとして、AWSが推奨する代表的な制御内容を実装

# AWS Organizations の情報を取得
data "aws_organizations_organization" "this" {}


# ルート直下の OU 一覧を取得
data "aws_organizations_organizational_units" "root_ous" {
  parent_id = data.aws_organizations_organization.this.roots[0].id
}

# Suspended OU の ID を抽出
locals {
  suspended_ou_id = one([
    for ou in data.aws_organizations_organizational_units.root_ous.children : ou.id
    if ou.name == "Suspended"
  ])
}

# 1.ルートユーザ禁止
resource "aws_organizations_policy" "deny_root" {
  name        = "SCP-DenyRootUser"
  description = "ルートユーザー使用時にすべてのアクションを拒否する"
  type        = "SERVICE_CONTROL_POLICY"
  content     = file("${path.module}/policies/deny_root.json")
  tags        = var.tags
}

resource "aws_organizations_policy_attachment" "deny_root" {
  policy_id = aws_organizations_policy.deny_root.id
  target_id = data.aws_organizations_organization.this.roots[0].id
}


# 2.組織離脱禁止
resource "aws_organizations_policy" "deny_leaving_org" {
  name        = "SCP-DenyLeavingOrganization"
  description = "AWS Organizationsからの離脱を拒否する"
  type        = "SERVICE_CONTROL_POLICY"
  content     = file("${path.module}/policies/deny_leaving_org.json")
  tags        = var.tags
}

resource "aws_organizations_policy_attachment" "deny_leaving_org" {
  policy_id = aws_organizations_policy.deny_leaving_org.id
  target_id = data.aws_organizations_organization.this.roots[0].id
}

# 3.  未承認リージョン禁止
# 参考 https://dev.classmethod.jp/articles/scp-region-limit/
resource "aws_organizations_policy" "deny_unapproved_regions" {
  name        = "SCP-DenyUnapprovedRegions"
  description = "未承認リージョンでのアクションを拒否する"
  type        = "SERVICE_CONTROL_POLICY"
  content     = file("${path.module}/policies/deny_unapproved_regions.json")
  tags        = var.tags
}

resource "aws_organizations_policy_attachment" "deny_unapproved_regions" {
  policy_id = aws_organizations_policy.deny_unapproved_regions.id
  target_id = data.aws_organizations_organization.this.roots[0].id
}

# 4.主要セキュリティサービスを止めたり削除する操作を全面的に禁止するSCP
resource "aws_organizations_policy" "deny_disable_sec_services" {
  name        = "SCP-DenyDisablingSecurityServices"
  description = "セキュリティサービスを無効化するアクションを拒否する"
  type        = "SERVICE_CONTROL_POLICY"
  content     = file("${path.module}/policies/deny_disable_security_services.json")
  tags        = var.tags
}

resource "aws_organizations_policy_attachment" "deny_disable_sec_services" {
  policy_id = aws_organizations_policy.deny_disable_sec_services.id
  target_id = data.aws_organizations_organization.this.roots[0].id
}

# 5.suspendedアカウントでの全アクション禁止
resource "aws_organizations_policy" "deny_all_suspended" {
  name        = "SCP-DenyAllSuspended"
  description = "suspendedアカウントでの全アクションを拒否する"
  type        = "SERVICE_CONTROL_POLICY"
  content     = file("${path.module}/policies/deny_all_suspended.json")
  tags        = var.tags
}

resource "aws_organizations_policy_attachment" "deny_all_suspended" {
  policy_id = aws_organizations_policy.deny_all_suspended.id
  target_id = local.suspended_ou_id
}

# 6.カスタムSCPの作成・アタッチ
resource "aws_organizations_policy" "addpolicy" {
  for_each    = var.add_scps
  name        = each.key
  description = each.value.description
  type        = "SERVICE_CONTROL_POLICY"
  content     = file("${path.root}/policies/${each.value.file}") # applyした時の/policies/以下のファイル名
  tags        = var.tags
}

resource "aws_organizations_policy_attachment" "addpolicy" {
  for_each  = aws_organizations_policy.addpolicy
  policy_id = each.value.id
  target_id = var.add_scps[each.key].target_id
}

