include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/tgw_route"
}

dependency "tgw_hub" {
  config_path = "../tgw_hub"
}

dependency "vpc" {
  config_path = "../vpc"
}

dependency "tgw_attachment" {
  config_path = "../tgw_attachment"
}

inputs = {
  # Transit Gateway
  transit_gateway_id  = dependency.tgw_hub.outputs.tgw_id

  # VPC Attachment IDs
  # - 同じアカウントの VPC は dependency から取得
  # - 他アカウントの VPC はハードコード
  tgw_attachment_ids = merge(
    {
      network = dependency.tgw_attachment.outputs.tgw_attachment_id
    },
    {
      # 他アカウント VPC アタッチメント ID は手動入力
      dev = "tgw-attach-0d6481d09e556e832"
    }
  )

  # Route Tables to create
  route_tables = [
    { name = "all-rtb" }
  ]

  # Associations: アタッチメントが入ってくるときに使うテーブル
  route_table_associations = [
    { vpc = "dev", route_table = "all-rtb" },
    { vpc = "network", route_table = "all-rtb" }
  ]

  # Propagations: アタッチメントのルートをどのテーブルに書き込むか
  route_table_propagations = [
    { vpc = "dev", route_table = "all-rtb" },
    { vpc = "network", route_table = "all-rtb" }
  ]
}
