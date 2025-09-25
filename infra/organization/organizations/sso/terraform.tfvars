# terraform.tfvars

# 環境（dev | stg | prod | sandbox）
env = "prod"

# アプリケーション名（3–32 文字、英数/ハイフン/アンダースコア）
app_name = "minimal-gov-sso"

# AWS リージョン（例: ap-northeast-1）
region = "ap-northeast-1"

# 共通タグ
tags = {
  Project = "minimal-gov"
}

# Organization の tfstate 情報
org_state_bucket = "aws-remotebackend-bootstrap-tfstate-ap-northeast-1-653502182074" # マスク済み
org_state_key    = "state/organization/terraform.tfstate"
org_state_region = "ap-northeast-1"

# Identity Center ユーザーID（UUIDはマスク済み）
user_id = "f774da98-8011-7026-2c88-b28e7383e802"

# 割り当て先アカウント（SSO使用アカウントを列挙）
assigned_accounts = ["dev", "network", "security", "onprem", "ops","log"]