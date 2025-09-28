output "assessment_target" {
  description = "AWS Inspector assessment target"
  value       = var.enabled ? module.inspector.inspector_assessment_target : null
}

output "assessment_template" {
  description = "AWS Inspector assessment template"
  value       = var.enabled ? module.inspector.aws_inspector_assessment_template : null
}

output "event_rule" {
  description = "CloudWatch event rule triggering Inspector assessments"
  value       = var.enabled ? module.inspector.aws_cloudwatch_event_rule : null
}

output "event_target" {
  description = "CloudWatch event target used to invoke Inspector"
  value       = var.enabled ? module.inspector.aws_cloudwatch_event_target : null
}

output "delegated_administrator" {
  description = "Delegated administrator registration resource"
  value       = var.enable_delegated_administrator ? aws_organizations_delegated_administrator.inspector[0] : null
}

output "resource_name" {
  description = "Computed Inspector resource name"
  value       = local.inspector_resource_name
}

output "tags" {
  description = "Merged tag map applied to Inspector resources"
  value       = local.merged_tags
}
