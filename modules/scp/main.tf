# --- ポリシー定義 ---
# 1) ルートユーザ禁止
resource "aws_organizations_policy" "deny_root" {
  name        = "SCP-DenyRootUser"
  description = "Deny all actions when using the root user"
  type        = "SERVICE_CONTROL_POLICY"
  content     = file("${path.module}/policies/deny_root.json")
  tags        = var.tags
}

# 2) 組織離脱禁止
resource "aws_organizations_policy" "deny_leaving_org" {
  name        = "SCP-DenyLeavingOrganization"
  description = "Deny leaving AWS Organization"
  type        = "SERVICE_CONTROL_POLICY"
  content     = file("${path.module}/policies/deny_leaving_org.json")
  tags        = var.tags
}

# 3) 未承認リージョン禁止
resource "aws_organizations_policy" "deny_unapproved_regions" {
  name        = "SCP-DenyUnapprovedRegions"
  description = "Deny actions in regions not in the allowed list"
  type        = "SERVICE_CONTROL_POLICY"
  content = templatefile("${path.module}/policies/deny_unapproved_regions.json.tftpl", {
    allowed_regions = var.allowed_regions
  })
  tags = var.tags
}

# 4) GuardDuty / CloudTrail / Config の無効化禁止（将来の強制に備える）
resource "aws_organizations_policy" "deny_disable_sec_services" {
  name        = "SCP-DenyDisablingSecurityServices"
  description = "Deny disabling GuardDuty, CloudTrail, AWS Config"
  type        = "SERVICE_CONTROL_POLICY"
  content     = templatefile("${path.module}/policies/deny_disable_security_services.json.tftpl", {})
  tags        = var.tags
}

# --- アタッチ（attach_mapに従う） ---
locals {
  policies = {
    deny_root                 = aws_organizations_policy.deny_root.id
    deny_leaving_org          = aws_organizations_policy.deny_leaving_org.id
    deny_unapproved_regions   = aws_organizations_policy.deny_unapproved_regions.id
    deny_disable_sec_services = aws_organizations_policy.deny_disable_sec_services.id
  }
}

# 動的にターゲットへ貼り付け
resource "aws_organizations_policy_attachment" "attach" {
  for_each = {
    for k, v in var.attach_map : k => {
      policy_id = lookup(local.policies, k)
      targets   = v
    }
  }

  policy_id = each.value.policy_id
  target_id = element([
    for t in each.value.targets : lookup(var.targets, t)
  ], 0)

  # 1つの定義で複数ターゲットへ貼るため、count式に変更
  count = length(each.value.targets) > 0 ? length(each.value.targets) : 0
  # 上の target_id を count.index 化
  lifecycle { create_before_destroy = true }
}

# 上の count を成立させるための再定義（Terraformの制約回避）
resource "aws_organizations_policy_attachment" "attach_multi" {
  for_each = {
    for k, v in var.attach_map :
    k => {
      policy_id  = lookup(local.policies, k)
      target_ids = [for t in v : lookup(var.targets, t)]
    }
  }

  policy_id = each.value.policy_id
  target_id = each.value.target_ids[count.index]

  count = length(each.value.target_ids)
}

output "policy_ids" {
  value = {
    deny_root                 = aws_organizations_policy.deny_root.id
    deny_leaving_org          = aws_organizations_policy.deny_leaving_org.id
    deny_unapproved_regions   = aws_organizations_policy.deny_unapproved_regions.id
    deny_disable_sec_services = aws_organizations_policy.deny_disable_sec_services.id
  }
}
