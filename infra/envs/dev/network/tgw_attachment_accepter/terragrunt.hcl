include "root" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../../../modules/network/tgw_vpc_attachment_accepter"
}

inputs = {
  transit_gateway_attachment_id = "tgw-attach-0d6481d09e556e832"
}
