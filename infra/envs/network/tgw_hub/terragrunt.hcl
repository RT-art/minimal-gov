include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/tgw_hub"
}

inputs = {
  # Transit Gateway
  description                     = "Transit Gateway"
  amazon_side_asn                 = 64512
  auto_accept_shared_attachments  = false
  default_route_table_association = false
  default_route_table_propagation = false

  # route_tables = {
  #   dev = {
  #     name = "dev-tgw-rtb"
  #   }
  # }
  #
  # route_table_associations = {
  #   vpc1 = {
  #     vpc         = "vpc1"
  #     route_table = "dev"
  #   }
  # }
  #
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
  #
  # tgw_attachment_ids = {
  #   dev = "tgw-attach-xxxxxxxxxxxxxx"
  # }
  #
  # tgw_route_table_ids = {
  #   dev = "tgw-rtb-xxxxxxxxxxxxxx"
  # }
}
