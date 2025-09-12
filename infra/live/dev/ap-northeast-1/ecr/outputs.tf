output "repository_url" {
  description = "URL of the created ECR repository"
  value       = module.ecr.repository_url
}

output "repository_arn" {
  description = "ARN of the created ECR repository"
  value       = module.ecr.repository_arn
}
