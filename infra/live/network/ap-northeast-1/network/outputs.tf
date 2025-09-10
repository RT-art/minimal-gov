output "vpc_id" {
  description = "ID of the network VPC"
  value       = module.network_vpc.vpc_id
}

output "tgw_id" {
  description = "ID of the Transit Gateway"
  value       = module.tgw.tgw_id
}

output "tgw_vpc_attachment_id" {
  description = "ID of the TGW VPC attachment"
  value       = module.tgw_attachment.attachment_id
}
