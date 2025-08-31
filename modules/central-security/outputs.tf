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
