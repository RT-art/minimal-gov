###############################################
# Amazon Inspector スケジュール設定
###############################################
module "inspector" {
  source  = "cloudposse/inspector/aws"
  version = "~> 0.4"

  enabled        = var.enabled
  namespace      = local.resolved_namespace
  environment    = var.env
  stage          = local.resolved_stage
  name           = var.name
  attributes     = var.attributes
  delimiter      = var.delimiter
  labels_as_tags = var.labels_as_tags
  tags           = local.merged_tags

  create_iam_role               = var.create_iam_role
  iam_role_arn                  = var.iam_role_arn
  enabled_rules                 = var.enabled_rules
  assessment_duration           = var.assessment_duration
  assessment_event_subscription = var.assessment_event_subscription
  schedule_expression           = var.schedule_expression
  event_rule_description        = var.event_rule_description
}

###############################################
# AWS Organizations の委任管理者登録（任意）
###############################################
resource "aws_organizations_delegated_administrator" "inspector" {
  count = var.enable_delegated_administrator ? 1 : 0

  account_id        = local.delegated_admin_account_id
  service_principal = local.delegated_admin_service_principal
}
