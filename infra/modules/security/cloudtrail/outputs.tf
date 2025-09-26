output "cloudtrail_id" {
  description = "Identifier of the CloudTrail trail"
  value       = aws_cloudtrail.this.id
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail trail"
  value       = aws_cloudtrail.this.arn
}

output "cloudtrail_home_region" {
  description = "Region where the CloudTrail was created"
  value       = aws_cloudtrail.this.home_region
}
