###############################################
# AWS Config aggregator (Cloud Posse wrapper)
###############################################

module "config_aggregator" {
  source  = "cloudposse/config/aws"
  version = "~> 1.5"

  enabled = var.enabled
  context = local.context

  s3_bucket_id  = var.config_bucket_name
  s3_bucket_arn = var.config_bucket_arn
  s3_key_prefix = var.s3_key_prefix

  global_resource_collector_region   = var.global_resource_collector_region
  central_resource_collector_account = var.central_resource_collector_account_id
  child_resource_collector_accounts  = local.child_account_set
  disabled_aggregation_regions       = var.disabled_aggregation_regions
  is_organization_aggregator         = var.is_organization_aggregator

  create_iam_role                         = var.create_config_iam_role
  create_organization_aggregator_iam_role = var.create_organization_aggregator_iam_role
  iam_role_arn                            = var.config_iam_role_arn
  iam_role_organization_aggregator_arn    = var.organization_aggregator_iam_role_arn

  create_sns_topic                       = var.create_findings_topic
  findings_notification_arn              = var.findings_notification_arn
  subscribers                            = var.sns_subscribers
  sns_encryption_key_id                  = local.resolved_sns_encryption_key
  sqs_queue_kms_master_key_id            = local.resolved_sqs_queue_kms_master_key
  allowed_aws_services_for_sns_published = var.allowed_services_for_findings_topic
  allowed_iam_arns_for_sns_publish       = var.allowed_iam_arns_for_findings_topic

  managed_rules  = var.managed_rules
  recording_mode = var.recording_mode
}
