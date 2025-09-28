###############################################
# CloudWatch Logs グループ本体
###############################################
module "log_groups" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/log-group"
  version = "~> 5.0"

  for_each = local.normalized_log_groups

  name              = each.value.resolved_name
  retention_in_days = each.value.retention_in_days
  kms_key_id        = each.value.kms_key_arn
  log_group_class   = each.value.log_group_class
  skip_destroy      = each.value.skip_destroy
  tags              = each.value.resolved_tags
}

###############################################
# サブスクリプションフィルター (中央アカウント転送)
###############################################
resource "aws_cloudwatch_log_subscription_filter" "this" {
  for_each = local.subscription_filters

  name            = each.value.name
  log_group_name  = module.log_groups[each.key].cloudwatch_log_group_name
  destination_arn = each.value.destination_arn
  filter_pattern  = each.value.filter_pattern
  role_arn        = each.value.role_arn
  distribution    = each.value.distribution
}

###############################################
# リソースポリシー (組織アカウント向けアクセス)
###############################################
resource "aws_cloudwatch_log_resource_policy" "this" {
  for_each = var.resource_policies

  policy_name     = each.key
  policy_document = each.value.policy_document
}
