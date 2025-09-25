###############################################
# CloudTrail (via Cloud Posse module)
###############################################
module "cloudtrail" {
  source = "git::https://github.com/cloudposse/terraform-aws-cloudtrail.git?ref=0.9.0"

  enabled = var.enabled

  # Collapse naming to a single label so the final ID matches the resolved name
  name        = local.resolved_trail_name
  label_order = ["name"]
  tags        = local.merged_tags

  s3_bucket_name             = var.s3_bucket_name
  s3_key_prefix              = var.s3_key_prefix
  kms_key_arn                = local.normalized_kms_key_arn
  sns_topic_name             = var.sns_topic_name
  cloud_watch_logs_group_arn = local.normalized_cloudwatch_logs_arn
  cloud_watch_logs_role_arn  = local.normalized_cloudwatch_logs_role

  enable_logging                = var.enable_logging
  enable_log_file_validation    = var.enable_log_file_validation
  is_multi_region_trail         = var.is_multi_region_trail
  include_global_service_events = var.include_global_service_events
  is_organization_trail         = var.is_organization_trail

  insight_selector        = var.insight_selector
  event_selector          = var.event_selector
  advanced_event_selector = var.advanced_event_selector
}
