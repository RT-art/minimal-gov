########################
# GuardDuty
########################
output "guardduty_detector_id" {
  description = "The ID of the GuardDuty detector"
  value       = aws_guardduty_detector.this.id
}

########################
# Security Hub
########################
output "securityhub_account_id" {
  description = "The AWS SecurityHub account ID"
  value       = aws_securityhub_account.this.id
}

output "securityhub_finding_aggregator_arn" {
  description = "The ARN of the Security Hub finding aggregator"
  value       = aws_securityhub_finding_aggregator.this.arn
}

########################
# AWS Config Aggregator
########################
output "config_aggregator_id" {
  description = "The ID of the AWS Config aggregator"
  value       = aws_config_configuration_aggregator.org.id
}

output "config_aggregator_arn" {
  description = "The ARN of the AWS Config aggregator"
  value       = aws_config_configuration_aggregator.org.arn
}

########################
# CloudTrail (module)
########################
output "cloudtrail_trail_name" {
  description = "The name of the CloudTrail trail created by the module"
  value       = module.org_cloudtrail.trail_name
}

output "cloudtrail_trail_arn" {
  description = "The ARN of the CloudTrail trail created by the module"
  value       = module.org_cloudtrail.trail_arn
}

output "cloudtrail_s3_bucket" {
  description = "The S3 bucket name used by the CloudTrail trail"
  value       = module.org_cloudtrail.s3_bucket_name
}
