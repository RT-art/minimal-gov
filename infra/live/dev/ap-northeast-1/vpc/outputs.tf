output "vpc_id" {
  description = "ID of the dev VPC"
  value       = module.dev_vpc.vpc_id
}

output "private_subnet_ids_by_az" {
  description = "Map of private subnet IDs by AZ"
  value       = module.dev_vpc.private_subnet_ids_by_az
}

output "route_table_ids" {
  description = "List of route table IDs"
  value       = module.dev_vpc.route_table_ids
}
