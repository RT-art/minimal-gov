output "tgw_id" {
  description = "ID of the Transit Gateway"
  value       = module.tgw.tgw_id
}

output "tgw_vpc_attachment_id" {
  description = "ID of the TGW VPC attachment"
  value       = module.tgw_attachment.attachment_id
}

output "vpc_id" {
  description = "ID of the network VPC"
  value       = module.network_vpc.vpc_id
}

output "subnets" {
  description = "Subnet map keyed by name (id, cidr, az)"
  value       = module.workload_vpc.subnets
}

output "route_table_id" {
  description = "Private Route Table ID"
  value       = module.workload_vpc.route_table_id
}

output "flow_log_id" {
  description = "Flow Log ID"
  value       = module.workload_vpc.flow_log_id
}

output "flow_log_role_arn" {
  description = "Flow Logs IAM Role ARN"
  value       = module.workload_vpc.flow_log_role_arn
}

output "tgw_attachment_id" {
  description = "ID of the TGW VPC attachment"
  value       = module.tgw_attachment.attachment_id
}

output "tgw_attachment_arn" {
  description = "ARN of the TGW VPC attachment"
  value       = module.tgw_attachment.attachment_arn
}

output "tgw_attachment_subnet_ids" {
  description = "Subnet IDs used for TGW attachment"
  value       = local.tgw_attachment_subnet_ids
}

output "endpoint_sg_id" {
  description = "Security Group ID used for all Interface endpoints"
  value       = module.vpc_endpoints.endpoint_sg_id
}

output "interface_endpoint_ids" {
  description = "Map of Interface VPC endpoint IDs"
  value       = module.vpc_endpoints.interface_endpoint_ids
}

output "gateway_endpoint_ids" {
  description = "Map of Gateway VPC endpoint IDs"
  value       = module.vpc_endpoints.gateway_endpoint_ids
}

output "all_endpoint_ids" {
  description = "Map of all VPC endpoint IDs"
  value       = module.vpc_endpoints.all_endpoint_ids
}

output "interface_endpoint_dns_entries" {
  description = "DNS entries for all Interface VPC endpoints"
  value       = module.vpc_endpoints.interface_endpoint_dns_entries
}

output "customer_gateway_id" {
  description = "Customer Gateway ID"
  value       = module.vpn.customer_gateway_id
}

output "vpn_connection_id" {
  description = "VPN Connection ID"
  value       = module.vpn.vpn_connection_id
}

output "vpn_connection_tunnel1_address" {
  description = "VPN Tunnel 1 IP"
  value       = module.vpn.vpn_connection_tunnel1_address
}

output "vpn_connection_tunnel2_address" {
  description = "VPN Tunnel 2 IP"
  value       = module.vpn.vpn_connection_tunnel2_address
}
