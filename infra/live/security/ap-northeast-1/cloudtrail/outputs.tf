output "trail_arn" {
  description = "ARN of the CloudTrail trail"
  value       = module.cloudtrail.trail_arn
}

output "bucket_name" {
  description = "S3 bucket name for CloudTrail logs"
  value       = module.cloudtrail.bucket_name
}
