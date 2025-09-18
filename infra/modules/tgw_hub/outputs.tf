output "tgw_id" {
  description = "Transit Gateway ID"
  value       = aws_ec2_transit_gateway.this.id
}

output "tgw_arn" {
  description = "Transit Gateway ARN"
  value       = aws_ec2_transit_gateway.this.arn
}

output "ram_share_arn" {
  value       = try(aws_ram_resource_share.this.arn, null)
  description = "The ARN of the RAM resource share"
}