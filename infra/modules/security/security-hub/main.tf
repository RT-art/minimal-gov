###############################################
# Security Hub 基本設定
###############################################
module "security_hub" {
  source  = "cloudposse/security-hub/aws"
  version = "~> 0.12.0"

  enabled = var.enabled

  # Cloud Posse モジュールの命名情報 (タグにも反映)
  namespace = var.app_name
  stage     = var.env
  name      = "securityhub"

  tags = local.merged_tags

  enable_default_standards = var.enable_default_standards
  enabled_standards        = var.enabled_standards

  create_sns_topic = var.create_sns_topic
  subscribers      = var.subscribers

  imported_findings_notification_arn        = var.imported_findings_notification_arn
  cloudwatch_event_rule_pattern_detail_type = var.cloudwatch_event_rule_pattern_detail_type

  finding_aggregator_enabled      = var.finding_aggregator_enabled
  finding_aggregator_linking_mode = var.finding_aggregator_linking_mode
  finding_aggregator_regions      = local.normalized_finding_aggregator_regions
}

###############################################
# Organizations における委任管理者設定
###############################################
resource "aws_securityhub_organization_admin_account" "this" {
  count = var.enabled && local.should_configure_organization_resources ? 1 : 0

  admin_account_id = local.delegated_admin_account_id
}

###############################################
# 組織全体の設定 (自動有効化 / 中央集約)
###############################################
resource "aws_securityhub_organization_configuration" "this" {
  count = var.enabled && local.should_configure_organization_resources ? 1 : 0

  auto_enable           = var.organization_auto_enable
  auto_enable_standards = local.normalized_auto_enable_standards

  dynamic "organization_configuration" {
    for_each = local.is_central_configuration ? [1] : []
    content {
      configuration_type = local.normalized_configuration_type
    }
  }

  depends_on = [
    module.security_hub,
    aws_securityhub_organization_admin_account.this,
  ]
}
