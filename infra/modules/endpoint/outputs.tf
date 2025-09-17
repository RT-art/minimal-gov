output "vpc_endpoint_ids" {
  description = "IDs of created VPC Endpoints"
  value       = module.vpc_endpoints.endpoints
}

output "security_group_id" {
  description = "Security group ID for VPC Endpoints"
  value       = module.vpce_sg.security_group_id
}
