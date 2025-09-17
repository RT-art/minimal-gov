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
  db_name        = "appdb"
  username       = "admin"

  # ネットワーク設定（VPCモジュールのoutputを参照）
  vpc_id     = "vpc-0abc123456789def0"
  subnet_ids = ["subnet-0aaa1111", "subnet-0bbb2222"]

  # RDSへ接続を許可するSG（ECSや踏み台など）
  # まだ無ければ null のままでも可
  allowed_sg_id = null
}
