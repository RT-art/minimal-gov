include "root" {
  path = find_in_parent_folders("env.hcl")
}

# Networkアカウント側のTGWを参照する前提のため、このスタックは適用対象外
skip = true

terraform {
  source = "../../../../../modules/network/tgw_hub"
}

inputs = {
  app_name                        = "minimal-gov-prod-workloads-tgw-hub"
  description                     = "Transit Gateway (workloads local ref)"
  amazon_side_asn                 = 64512
  auto_accept_shared_attachments  = true
  default_route_table_association = false
  default_route_table_propagation = false
}
