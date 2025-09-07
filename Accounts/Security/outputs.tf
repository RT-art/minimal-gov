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
output "securityhub_finding_aggregator_arn" {
  description = "ARN of Security Hub finding aggregator (home region)"
  value       = aws_securityhub_finding_aggregator.this.id
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
  value       = aws_cloudtrail.org.name
}

output "cloudtrail_trail_arn" {
  description = "The ARN of the CloudTrail trail created by the module"
  value       = aws_cloudtrail.org.arn
}

output "cloudtrail_s3_bucket" {
  description = "The S3 bucket name used by the CloudTrail trail"
  value       = aws_s3_bucket.cloudtrail.bucket
}
