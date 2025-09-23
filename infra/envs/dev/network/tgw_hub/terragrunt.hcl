include "root" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../../../modules/network/tgw_hub"
}

inputs = {
  # Transit Gateway
  description                     = "Transit Gateway"
  amazon_side_asn                 = 64512
  auto_accept_shared_attachments  = true
  default_route_table_association = false
  default_route_table_propagation = false
}