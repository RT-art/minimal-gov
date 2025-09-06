 # scp module
 # ベースラインSCPとして、AWSが推奨する代表的な制御内容を実装

# 1.ルートユーザ禁止
resource "aws_organizations_policy" "deny_root" {
  name        = "SCP-DenyRootUser"
  description = "ルートユーザー使用時にすべてのアクションを拒否する"
  type        = "SERVICE_CONTROL_POLICY"
  content     = file("${path.module}/policies/deny_root.json")
  tags        = var.tags
}

# 2.組織離脱禁止
resource "aws_organizations_policy" "deny_leaving_org" {
  name        = "SCP-DenyLeavingOrganization"
  description = "AWS Organizationsからの離脱を拒否する"
  type        = "SERVICE_CONTROL_POLICY"
  content     = file("${path.module}/policies/deny_leaving_org.json")
  tags        = var.tags
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

# 4.主要セキュリティサービスを止めたり削除する操作を全面的に禁止するSCP
resource "aws_organizations_policy" "deny_disable_sec_services" {
  name        = "SCP-DenyDisablingSecurityServices"
  description = "セキュリティサービスを無効化するアクションを拒否する"
  type        = "SERVICE_CONTROL_POLICY"
  content     = file("${path.module}/policies/deny_disable_security_services.json")
  tags        = var.tags
}

# suspendedアカウントでの全アクション禁止
resource "aws_organizations_policy" "deny_all_suspended" {
  name        = "SCP-DenyAllSuspended"
  description = "suspendedアカウントでの全アクションを拒否する"
  type        = "SERVICE_CONTROL_POLICY"
  content     = file("${path.module}/policies/deny_all_suspended.json")
  tags        = var.tags
}

locals {
  # 管理するポリシーIDをわかりやすくまとめる
  policies = {
    deny_root                 = aws_organizations_policy.deny_root.id
    deny_leaving_org          = aws_organizations_policy.deny_leaving_org.id
    deny_unapproved_regions   = aws_organizations_policy.deny_unapproved_regions.id
    deny_disable_sec_services = aws_organizations_policy.deny_disable_sec_services.id
    deny_all_suspended        = aws_organizations_policy.deny_all_suspended.id
  }

  # ポリシーとターゲットの対応表をシンプルに記述
  attach_map = {
    deny_root                 = [var.account_root]
    deny_leaving_org          = [var.org_id]
    deny_unapproved_regions   = var.security_accounts
    deny_disable_sec_services = var.security_accounts
    deny_all_suspended        = var.suspended_accounts
  }
}

 # 各ポリシーをターゲットに付与
resource "aws_organizations_policy_attachment" "this" {
  for_each = {
    for policy_key, targets in local.attach_map :
    policy_key => {
      policy_id = local.policies[policy_key]
      targets   = targets
    }
  }

  # それぞれのターゲットにアタッチ
  policy_id = each.value.policy_id
  target_id = each.value.targets[0]
}

output "policy_ids" {
  description = "Managed SCP policy IDs"
  value       = local.policies
}

