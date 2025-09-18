output "tgw_attachment_id" {
  description = "ID of the accepted TGW VPC attachment"
  value       = aws_ec2_transit_gateway_vpc_attachment_accepter.this.id
}

