output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "subnets" {
  description = "Subnets map keyed by name"
  value       = module.vpc.subnets
}

output "route_table_id" {
  description = "Private Route Table ID"
  value       = module.vpc.route_table_id
}

output "flow_log_id" {
  description = "Flow Log ID"
  value       = module.vpc.flow_log_id
}

output "tgw_attachment_id" {
  description = "TGW VPC Attachment ID"
  value       = module.tgw_attachment.attachment_id
}

output "endpoint_sg_id" {
  description = "Security Group for interface endpoints"
  value       = module.endpoints.endpoint_sg_id
}

output "interface_endpoint_ids" {
  description = "Interface endpoint IDs"
  value       = module.endpoints.interface_endpoint_ids
}

output "gateway_endpoint_ids" {
  description = "Gateway endpoint IDs"
  value       = module.endpoints.gateway_endpoint_ids
}
