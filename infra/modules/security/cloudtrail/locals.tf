locals {
  # Keep the trail name predictable so that log locations remain stable across accounts
  resolved_trail_name = coalesce(var.trail_name, "${var.app_name}-${var.env}-cloudtrail")

  # Ensure mandatory tags (Application/Environment) are available even if not provided upstream
  merged_tags = merge(
    {
      Name        = local.resolved_trail_name
      Application = var.app_name
      Environment = var.env
    },
    var.tags,
  )

  # No normalization required for native resource; keep raw values
  normalized_kms_key_arn          = var.kms_key_arn
  normalized_cloudwatch_logs_arn  = var.cloudwatch_logs_group_arn
  normalized_cloudwatch_logs_role = var.cloudwatch_logs_role_arn
}
