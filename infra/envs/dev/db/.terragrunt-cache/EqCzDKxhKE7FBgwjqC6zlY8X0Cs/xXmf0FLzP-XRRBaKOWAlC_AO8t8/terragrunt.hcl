include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../modules/rds"
}

dependency "vpc" {
  config_path = "../network/vpc"
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
