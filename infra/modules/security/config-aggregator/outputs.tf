output "configuration_recorder_id" {
  description = "Identifier for the AWS Config recorder"
  value       = var.enabled ? module.config_aggregator.aws_config_configuration_recorder_id : null
}

output "config_role_arn" {
  description = "ARN of the IAM role used by the AWS Config recorder"
  value       = var.enabled ? module.config_aggregator.iam_role : null
}

output "organization_aggregator_role_arn" {
  description = "ARN of the IAM role used by the organization aggregator"
  value       = var.enabled && var.is_organization_aggregator ? module.config_aggregator.iam_role_organization_aggregator : null
}

output "config_findings_topic" {
  description = "SNS topic module object for AWS Config compliance notifications"
  value       = var.enabled ? module.config_aggregator.sns_topic : null
}

output "config_findings_topic_subscriptions" {
  description = "SNS subscription resources created for AWS Config compliance notifications"
  value       = var.enabled ? module.config_aggregator.sns_topic_subscriptions : null
}
