# Provider 表示用リージョン（任意）
region = "ap-northeast-1"

# 共通タグ
app_name = "aws-org-bootstrap"
env      = "prod"

# 任意（追加タグを付けたい場合）
tags = {
  Project = "minimal-gov"
}
# SCP で許可するリージョン
allowed_regions = [
  "ap-northeast-1",
  "us-east-1",
]

security_account_email = "rt.aws0+sec@gmail.com"

delegate_admin_for = [
  "guardduty.amazonaws.com",
  "config.amazonaws.com",
  "cloudtrail.amazonaws.com",
  "securityhub.amazonaws.com",
]
