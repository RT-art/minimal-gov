include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/rds"
}

inputs = {
  # RDS 基本設定
  engine         = "mysql"
  engine_version = "8.0.36"
  instance_class = "db.t3.micro"
  db_name        = "minimal-gov-db"
  username       = "admin"

  # ネットワーク設定（VPCモジュールのoutputを参照）
  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = [
    dependency.vpc.outputs.subnets["rds-dev-a"].id,
    dependency.vpc.outputs.subnets["rds-dev-c"].id,
  ]


  # RDSへ接続を許可するSG（ECSや踏み台など）
  # まだ無ければ null のままでも可
  allowed_sg_id = null
}
