output "tgw_id" {
  description = "Transit Gateway ID"
  value       = aws_ec2_transit_gateway.this.id
}

output "tgw_arn" {
  description = "Transit Gateway ARN"
  value       = aws_ec2_transit_gateway.this.arn
}

output "tgw_route_table_ids" {
  description = "Map of TGW route table IDs (key=logical name)"
  value = {
    for k, rt in aws_ec2_transit_gateway_route_table.this : k => rt.id
  }
}

output "tgw_route_table_arns" {
  description = "Map of TGW route table ARNs (key=logical name)"
  value = {
    for k, rt in aws_ec2_transit_gateway_route_table.this : k => rt.arn
  }
}

output "ram_share_arn" {
  description = "ARN of the RAM share (if created)"
  value       = try(aws_ram_resource_share.this[0].arn, null)
}
