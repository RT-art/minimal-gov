output "securityhub_enabled_subscriptions" {
  description = "Identifiers for Security Hub standards subscriptions enabled by this module"
  value       = var.enabled ? module.security_hub.enabled_subscriptions : []
}

output "securityhub_sns_topic" {
  description = "SNS topic resource generated for Security Hub findings"
  value       = var.enabled && var.create_sns_topic ? module.security_hub.sns_topic : null
}

output "securityhub_sns_topic_subscriptions" {
  description = "SNS topic subscriptions generated for Security Hub findings"
  value       = var.enabled && var.create_sns_topic ? module.security_hub.sns_topic_subscriptions : null
}

output "securityhub_delegated_admin_account_id" {
  description = "AWS account ID registered as the Security Hub delegated administrator"
  value       = var.enabled && local.should_configure_organization_resources ? local.delegated_admin_account_id : null
}

output "securityhub_organization_admin_account_id" {
  description = "Resource ID of the Security Hub delegated administrator configuration"
  value = var.enabled && local.should_configure_organization_resources ? (
    aws_securityhub_organization_admin_account.this[0].id
  ) : null
}

output "securityhub_organization_configuration_id" {
  description = "Resource ID for the Security Hub organization-wide configuration"
  value = var.enabled && local.should_configure_organization_resources ? (
    aws_securityhub_organization_configuration.this[0].id
  ) : null
}
