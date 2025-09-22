output "tgw_route_table_ids" {
  description = "IDs of the created TGW route tables"
  value       = { for k, v in aws_ec2_transit_gateway_route_table.this : k => v.id }
}

output "tgw_route_table_association_ids" {
  description = "IDs of the TGW route table associations"
  value       = { for k, v in aws_ec2_transit_gateway_route_table_association.this : k => v.id }
}

output "tgw_route_table_propagation_ids" {
  description = "IDs of the TGW route table propagations"
  value       = { for k, v in aws_ec2_transit_gateway_route_table_propagation.this : k => v.id }
}