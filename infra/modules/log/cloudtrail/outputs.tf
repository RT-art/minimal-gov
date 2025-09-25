output "cloudtrail_id" {
  description = "Identifier of the CloudTrail trail"
  value       = module.cloudtrail.cloudtrail_id
}

output "cloudtrail_arn" {
  description = "ARN of the CloudTrail trail"
  value       = module.cloudtrail.cloudtrail_arn
}

output "cloudtrail_home_region" {
  description = "Region where the CloudTrail was created"
  value       = module.cloudtrail.cloudtrail_home_region
}
