###############################################
# CloudTrail (native resource)
###############################################

resource "aws_cloudtrail" "this" {
  name                       = local.resolved_trail_name
  s3_bucket_name             = var.s3_bucket_name
  s3_key_prefix              = var.s3_key_prefix != null ? var.s3_key_prefix : null
  kms_key_id                 = var.kms_key_arn != null ? var.kms_key_arn : null
  sns_topic_name             = var.sns_topic_name != null ? var.sns_topic_name : null
  cloud_watch_logs_group_arn = var.cloudwatch_logs_group_arn != null ? var.cloudwatch_logs_group_arn : null
  cloud_watch_logs_role_arn  = var.cloudwatch_logs_role_arn != null ? var.cloudwatch_logs_role_arn : null

  enable_logging                = var.enable_logging
  enable_log_file_validation    = var.enable_log_file_validation
  is_multi_region_trail         = var.is_multi_region_trail
  include_global_service_events = var.include_global_service_events
  is_organization_trail         = var.is_organization_trail

  tags = local.merged_tags

  dynamic "insight_selector" {
    for_each = var.insight_selector
    content {
      insight_type = insight_selector.value.insight_type
    }
  }

  dynamic "event_selector" {
    for_each = var.event_selector
    content {
      include_management_events        = event_selector.value.include_management_events
      read_write_type                  = event_selector.value.read_write_type
      exclude_management_event_sources = coalesce(event_selector.value.exclude_management_event_sources, [])

      dynamic "data_resource" {
        for_each = event_selector.value.data_resource
        content {
          type   = data_resource.value.type
          values = data_resource.value.values
        }
      }
    }
  }

  # advanced_event_selector is optional; skip if empty to avoid provider schema issues
  dynamic "advanced_event_selector" {
    for_each = var.advanced_event_selector
    content {
      name = try(advanced_event_selector.value.name, null)

      dynamic "field_selector" {
        for_each = advanced_event_selector.value.field_selector
        content {
          field           = field_selector.value.field
          ends_with       = try(field_selector.value.ends_with, null)
          not_ends_with   = try(field_selector.value.not_ends_with, null)
          equals          = try(field_selector.value.equals, null)
          not_equals      = try(field_selector.value.not_equals, null)
          starts_with     = try(field_selector.value.starts_with, null)
          not_starts_with = try(field_selector.value.not_starts_with, null)
        }
      }
    }
  }
}
