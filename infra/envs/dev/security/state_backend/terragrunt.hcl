include "root" {
  path = find_in_parent_folders("env.hcl")
}

# このスタックは共有のStateバケット自体を作成するブートストラップ用途。
# まだS3バックエンドが存在しないため、このディレクトリに限り backend=local を使用。
remote_state {
  backend = "local"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite"
  }
  config = {
    path = "terraform.tfstate"
  }
}

terraform {
  source = "../../../../modules/strage/backend"
}

inputs = {
  # required
  env      = "dev"
  app_name = "minimal-gov-dev-backend"
  region   = "ap-northeast-1"

  # tags
  tags = {
    Project = "minimal-gov"
  }

  # bucket behavior
  versioning_enabled = true
  force_destroy      = true
  lifecycle_days     = 30

  # cross-account access (root principals)
  allowed_account_ids = [
    "351277498040", # Dev
    "854669817093", # Network
    "454842420215", # Security
  ]
}

