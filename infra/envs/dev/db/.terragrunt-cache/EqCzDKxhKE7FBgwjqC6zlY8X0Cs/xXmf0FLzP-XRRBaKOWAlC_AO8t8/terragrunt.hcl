include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/rds"
}

dependency "vpc" {
  config_path = "../network/vpc"

  mock_outputs = {
    vpc_id = "vpc-00000000000000000"
    subnets = {
      "rds-dev-a" = { id = "subnet-aaa111aaa111aaa11", cidr = "10.0.30.0/24", az = "ap-northeast-1a" }
      "rds-dev-c" = { id = "subnet-ccc333ccc333ccc33", cidr = "10.0.31.0/24", az = "ap-northeast-1c" }
    }
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan"]
  mock_outputs_merge_with_state           = true
}

inputs = {
  # RDS 基本設定（PostgreSQL）
  engine         = "postgres"
  engine_version = null # null の場合、モジュール側で 15.x の最新マイナーを自動解決
  instance_class = "db.t3.micro"
  db_name        = "minimal_gov_db"
  username       = "dbadmin" # "admin" は予約語のため不可

  # ネットワーク設定（VPCモジュールのoutputを参照）
  vpc_id = dependency.vpc.outputs.vpc_id
  subnet_ids = [
    dependency.vpc.outputs.subnets["rds-dev-a"].id,
    dependency.vpc.outputs.subnets["rds-dev-c"].id,
  ]

  # データベースのポート（PostgreSQL = 5432）
  db_port = 5432

  # RDSへ接続を許可するSG（ECSや踏み台など）
  # まだ無ければ null のままでも可
  allowed_sg_id = null
}
