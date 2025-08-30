# ルートユーザ禁止
resource "aws_organizations_policy" "deny_root" {
  name        = "SCP-DenyRootUser"
  description = "Deny all actions when using the root user"
  type        = "SERVICE_CONTROL_POLICY"
  content     = file("${path.module}/policies/deny_root.json")
  tags        = var.tags
}

# 組織離脱禁止
resource "aws_organizations_policy" "deny_leaving_org" {
  name        = "SCP-DenyLeavingOrganization"
  description = "Deny leaving AWS Organization"
  type        = "SERVICE_CONTROL_POLICY"
  content     = file("${path.module}/policies/deny_leaving_org.json")
  tags        = var.tags
}

# 未承認リージョン禁止
resource "aws_organizations_policy" "deny_unapproved_regions" {
  name        = "SCP-DenyUnapprovedRegions"
  description = "Deny actions in regions not in the allowed list"
  type        = "SERVICE_CONTROL_POLICY"
  content = templatefile("${path.module}/policies/deny_unapproved_regions.json.tftpl", {
    allowed_regions = var.allowed_regions
  })
  tags = var.tags
}

# GuardDuty / CloudTrail / Config / SecurityHubの無効化禁止
resource "aws_organizations_policy" "deny_disable_sec_services" {
  name        = "SCP-DenyDisablingSecurityServices"
  description = "Deny disabling GuardDuty, CloudTrail, AWS Config"
  type        = "SERVICE_CONTROL_POLICY"
  content     = templatefile("${path.module}/policies/deny_disable_security_services.json.tftpl", {})
  tags        = var.tags
}

# suspendedアカウントでの全アクション禁止
resource "aws_organizations_policy" "deny_all_suspended" {
  name        = "SCP-DenyAllSuspended"
  description = "Deny all actions in suspended accounts"
  type        = "SERVICE_CONTROL_POLICY"
  content     = file("${path.module}/policies/deny_all_suspended.json")
  tags        = var.tags
}

# 
locals {
  attach_pairs = flatten([
    for policy_key, targets in var.attach_map : [
      for t in targets : {
        key       = "${policy_key}:${t}"
        policy_id = lookup(local.policies, policy_key)
        target_id = lookup(var.targets, t)
      }
    ]
  ])

  policies = {
    deny_root                 = aws_organizations_policy.deny_root.id
    deny_leaving_org          = aws_organizations_policy.deny_leaving_org.id
    deny_unapproved_regions   = aws_organizations_policy.deny_unapproved_regions.id
    deny_disable_sec_services = aws_organizations_policy.deny_disable_sec_services.id
    deny_all_suspended        = aws_organizations_policy.deny_all_suspended.id
  }
}

resource "aws_organizations_policy_attachment" "this" {
  for_each  = { for p in local.attach_pairs : p.key => p }
  policy_id = each.value.policy_id
  target_id = each.value.target_id
}

output "policy_ids" {
  value = local.policies
}

