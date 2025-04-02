# infrastructure_modules/network/outputs.tf

output "vpc_id" {
  description = "The ID of the VPC."
  value       = module.vpc.vpc_id
}

output "subnet_id" {
  description = "The ID of the public subnet created."
  # public_subnets はリストで返されるため、最初の要素 (インデックス 0) を取得
  value       = try(module.vpc.public_subnets[0], null)
}

output "internet_gateway_id" {
  description = "The ID of the Internet Gateway."
  value       = module.vpc.igw_id
}

output "public_route_table_id" {
  description = "The ID of the route table associated with the public subnet."
  # public_route_table_ids はリストで返されるため、最初の要素 (インデックス 0) を取得
  value       = try(module.vpc.public_route_table_ids[0], null)
}

# 元のコードで参照されていた Default Route Table ID も出力しておく (参考情報として)
output "default_route_table_id" {
    description = "The ID of the main/default route table."
    value = module.vpc.vpc_main_route_table_id
}