include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/tgw_vpc_attachment_accepter"
}

inputs = {
  transit_gateway_attachment_id = "tgw-attach-030ba6a66787ce2fa"
}

