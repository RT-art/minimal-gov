output "guardduty_detector" {
  description = "GuardDuty detector resource"
  value       = var.enabled ? module.guardduty_detector["primary"].guardduty_detector : null
}

output "guardduty_detector_id" {
  description = "GuardDuty detector identifier"
  value       = var.enabled ? module.guardduty_detector["primary"].guardduty_detector.id : null
}

output "guardduty_detector_arn" {
  description = "GuardDuty detector ARN"
  value       = var.enabled ? module.guardduty_detector["primary"].guardduty_detector.arn : null
}

output "guardduty_filter" {
  description = "GuardDuty finding filters"
  value       = var.enabled ? module.guardduty_detector["primary"].guardduty_filter : null
}

output "guardduty_ipset" {
  description = "GuardDuty IPSet configuration"
  value       = var.enabled ? module.guardduty_detector["primary"].guardduty_ipset : null
}

output "guardduty_threatintelset" {
  description = "GuardDuty threat intel set configuration"
  value       = var.enabled ? module.guardduty_detector["primary"].guardduty_threatintelset : null
}

output "guardduty_publishing" {
  description = "GuardDuty findings publishing configuration"
  value       = var.enabled ? module.guardduty_detector["primary"].guardduty_publishing : null
}

output "guardduty_s3_bucket" {
  description = "GuardDuty findings S3 bucket module"
  value       = var.enabled ? module.guardduty_detector["primary"].guardduty_s3_bucket : null
}

output "guardduty_replica_bucket" {
  description = "GuardDuty findings replica S3 bucket module"
  value       = var.enabled ? module.guardduty_detector["primary"].guardduty_replica_bucket : null
}

output "guardduty_log_bucket" {
  description = "GuardDuty findings log S3 bucket module"
  value       = var.enabled ? module.guardduty_detector["primary"].guardduty_log_bucket : null
}

output "guardduty_kms_key" {
  description = "KMS key used for GuardDuty findings encryption"
  value       = var.enabled ? module.guardduty_detector["primary"].guardduty_kms_key : null
}

output "guardduty_kms_replica_key" {
  description = "Replica KMS key for GuardDuty findings"
  value       = var.enabled ? module.guardduty_detector["primary"].guardduty_kms_replica_key : null
}

output "guardduty_delegated_admin_account" {
  description = "GuardDuty Organizations delegated admin resource"
  value       = var.enabled && var.enable_organization_admin ? module.organizations_admin["primary"].guardduty_delegated_admin_account : null
}

output "guardduty_organization_configuration" {
  description = "GuardDuty Organizations configuration"
  value       = var.enabled && var.enable_organization_admin ? module.organizations_admin["primary"].guardduty_organization_configuration : null
}
