data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

########################
# GuardDuty
########################

resource "aws_guardduty_detector" "this" {
  enable = true
}

resource "aws_guardduty_organization_configuration" "this" {
  detector_id                      = aws_guardduty_detector.this.id
  auto_enable_organization_members = "ALL" # 既存/新規すべて有効化
}

# 必要な機能を個別に有効化
resource "aws_guardduty_organization_configuration_feature" "s3_data_events" {
  detector_id = aws_guardduty_detector.this.id
  name        = "S3_DATA_EVENTS"
  auto_enable = "ALL"
}
resource "aws_guardduty_organization_configuration_feature" "rds_login_events" {
  detector_id = aws_guardduty_detector.this.id
  name        = "RDS_LOGIN_EVENTS"
  auto_enable = "ALL"
}

########################
# Security Hub
########################

resource "aws_securityhub_account" "this" {}

resource "aws_securityhub_organization_configuration" "central" {
  organization_configuration {
    configuration_type = "CENTRAL" # Delegated Adminのメンバーアカウントでのみ有効
  }
  auto_enable           = false
  auto_enable_standards = "NONE"
  depends_on            = [aws_securityhub_account.this]
}

resource "aws_securityhub_standards_subscription" "fsbp" {
  standards_arn = "arn:aws:securityhub:${data.aws_region.current.name}::standards/aws-foundational-security-best-practices/v/1.0.0"
  depends_on    = [aws_securityhub_account.this]
}
resource "aws_securityhub_standards_subscription" "cis" {
  standards_arn = "arn:aws:securityhub:::standards/cis-aws-foundations-benchmark/v/1.4.0"
  depends_on    = [aws_securityhub_account.this]
}

resource "aws_securityhub_finding_aggregator" "this" {
  linking_mode = "ALL_REGIONS"
}

########################
# AWS Config Aggregator
########################

resource "aws_config_configuration_aggregator" "org" {
  name = "org-aggregator"

  organization_aggregation_source {
    role_arn    = "arn:aws:iam::${var.org_management_account_id}:role/AWSConfigAggregatorRole"
    all_regions = true
  }
}

########################
# CloudTrail
########################

module "org_cloudtrail" {
  source = "../../modules/cloudtrail"

  trail_name            = "org-security-trail"
  s3_bucket_name        = "central-cloudtrail-logs-${data.aws_caller_identity.this.account_id}"
  is_organization_trail = true      # Org集約の中央トレイル
  multi_region_trail    = true      # 全リージョン
  enable_kms_encryption = false     # SSE-S3
  enable_logging        = true

  tags = {
    Project   = "security-central"
    ManagedBy = "terraform"
    Purpose   = "cloudtrail-org"
  }
}