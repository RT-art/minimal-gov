###############################################
# VPC
###############################################
output "vpc_id" {
  description = "作成された VPC の ID"
  value       = aws_vpc.this.id
}

output "vpc_name" {
  description = "作成された VPC の Name タグ"
  value       = aws_vpc.this.tags["Name"]
}

###############################################
# Subnets 
###############################################
# 名前付き map で subnet 情報を返す
output "subnets" {
  description = "サブネット名をキーにした Subnet 情報 (id, cidr, az)"
  value = {
    for k, s in aws_subnet.private : k => {
      id   = s.id
      cidr = s.cidr_block
      az   = s.availability_zone
    }
  }
}

###############################################
# Route Table
###############################################
output "route_table_id" {
  description = "プライベート用 Route Table の ID"
  value       = aws_route_table.private.id
}

# ###############################################
# # Flow Logs
# ###############################################
# output "flow_log_id" {
#   description = "作成された Flow Log の ID"
#   value       = aws_flow_log.this.id
# }
# 
# output "flow_log_role_arn" {
#   description = "Flow Logs 用 IAM Role ARN"
#   value       = aws_iam_role.flowlogs.arn
# }
