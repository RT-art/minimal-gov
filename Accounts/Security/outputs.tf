output "guardduty_detector_id" {
  value       = aws_guardduty_detector.this.id
  description = "GuardDuty detector ID"
}

output "securityhub_finding_aggregator_arn" {
  value       = aws_securityhub_finding_aggregator.this.arn
  description = "Security Hub finding aggregator ARN"
}

output "config_aggregator_id" {
  value       = aws_config_configuration_aggregator.org.id
  description = "Config aggregator ID"
}

output "cloudtrail_trail_arn" {
  value       = aws_cloudtrail.org.arn
  description = "Organization trail ARN"
}

output "trail_name" {
  description = "CloudTrail 名"
  value       = module.org_cloudtrail.trail_name
}


output "trail_arn" {
  description = "CloudTrail ARN"
  value       = module.org_cloudtrail.trail_arn
}


output "s3_bucket_name" {
  description = "ログ保存先 S3 バケット名"
  value       = module.org_cloudtrail.s3_bucket_name
}
