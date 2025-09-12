# === 必須系 ===
env      = "prod"
app_name = "minimal-gov-config"
region   = "ap-northeast-1"

# === 任意タグ ===
tags = {
  Project = "minimal-gov"
}

# === Config 設定 ===
bucket_name                 = "minimal-gov-config"
create_bucket               = true
aggregator_role_name        = "AWSConfigAggregatorRole"
snapshot_delivery_frequency = "TwentyFour_Hours"
