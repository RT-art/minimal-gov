###############################################
# Metadata
###############################################
env      = "dev"
app_name = "minimal-gov-network"
region   = "ap-northeast-1"
tags = {
  Project = "minimal-gov"
}

###############################################
# Transit Gateway
###############################################
description                     = "Transit Gateway"
amazon_side_asn                 = 64512
auto_accept_shared_attachments  = false
default_route_table_association = false
default_route_table_propagation = false

# Transit Gateway Route Tables
# route_tables = {
#   dev = {
#     name = "dev-tgw-rtb"
#   }
# }
# 
# # VPC アタッチメントとルートテーブルの紐付け
# route_table_associations = {
#   vpc1 = {
#     vpc         = "vpc1"
#     route_table = "dev"
#   }
# }
# 
# # 各 VPC から伝播するルートの宛先
# route_table_propagations = {
#   vpc1-to-spoke = {
#     vpc         = "vpc1"
#     route_table = "spoke"
#   }
#   vpc2-to-core = {
#     vpc         = "vpc2"
#     route_table = "core"
#   }
# }

# Route Table Association / Propagation
# tgw_attachment_ids = {
#   dev = "tgw-attach-xxxxxxxxxxxxxx"
# }
# tgw_route_table_ids = {
#   dev = "tgw-rtb-xxxxxxxxxxxxxx"
# }

# AWS RAM
ram_principals = [
  "o-abcd1234"
]

ram_share_name = "global-tgw-share"
ram_allow_external_principals = false