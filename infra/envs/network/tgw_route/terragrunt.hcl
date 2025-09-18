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

inputs = {
  # Transit Gateway
  transit_gateway_id  = dependency.tgw_hub.outputs.tgw_id
  tgw_route_table_ids = dependency.tgw_hub.outputs.tgw_route_table_ids

  # VPC Attachment IDs
  # - 同じアカウントの VPC は dependency から取得
  # - 他アカウントの VPC はハードコード
  tgw_attachment_ids = merge(
    {
      network = dependency.vpc.outputs.tgw_attachment_id
    },
    {
      # 他アカウント VPC アタッチメント ID は手動入力
      dev = "tgw-attach-xxxxxxxxxxxxxx"
    }
  )

  # Route Tables to create
  route_tables = [
    { name = "all-rtb" }
  ]

  # Associations: アタッチメントが入ってくるときに使うテーブル
  route_table_associations = [
    { vpc = "workload", route_table = "all-rtb" },
    { vpc = "network", route_table = "all-rtb" }
  ]

  # Propagations: アタッチメントのルートをどのテーブルに書き込むか
  route_table_propagations = [
    { vpc = "workload", route_table = "all-rtb" },
    { vpc = "network", route_table = "all-rtb" }
  ]
}
