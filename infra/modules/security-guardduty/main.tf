###############################################
# Minimal Gov: GuardDuty module
#
# このモジュールは、AWS GuardDuty を組織単位で有効化するための最小構成を提供します。
# 主な機能:
# - GuardDuty Detector の作成と有効化
# - 代表的な検出機能（S3、EKS、Lambda など）の有効化
# - Organization 連携設定により、組織メンバーアカウントを自動的に GuardDuty へ参加させる
#
# 設計指針:
# - ロジックは可能な限り単純化し、読みやすさを優先
# - セキュリティ既定値として、利用可能な検出機能はすべて有効化
# - 出力は上位モジュールが依存する最小限（Detector ID のみ）
###############################################

###############################################
# Locals
# - name_prefix は任意。Name タグ等で使用します。
###############################################
locals {
  name_prefix = var.name_prefix != null && var.name_prefix != "" ? var.name_prefix : "guardduty"

  # 追加構成が不要な GuardDuty 機能の一覧
  basic_features = [
    "S3_DATA_EVENTS",
    "EKS_AUDIT_LOGS",
    "LAMBDA_NETWORK_LOGS",
    "RDS_LOGIN_EVENTS",
    "EBS_MALWARE_PROTECTION",
  ]
}

###############################################
# GuardDuty Detector
# - アカウント / リージョン単位で GuardDuty を有効化するリソースです。
# - enable = true とすることで監視を開始します。
# - Name タグには name_prefix を付与します。
###############################################
resource "aws_guardduty_detector" "this" {
  enable = true

  tags = merge(
    {
      Name = "${local.name_prefix}-detector"
    },
    var.tags,
  )
}

###############################################
# GuardDuty Detector Features（追加設定不要分）
# - local.basic_features に定義した機能を一括で有効化します。
# - 代表例: S3 保護、EKS Audit Logs、Lambda ネットワークログ 等
###############################################
resource "aws_guardduty_detector_feature" "basic" {
  for_each    = toset(local.basic_features)
  detector_id = aws_guardduty_detector.this.id
  name        = each.value
  status      = "ENABLED"
}

###############################################
# GuardDuty Detector Feature（EKS Runtime Monitoring）
# - EKS ランタイム監視は追加設定が必要なため個別に記述します。
# - Add-on 管理を有効化することで、より深い検査を実施できます。
###############################################
resource "aws_guardduty_detector_feature" "eks_runtime_monitoring" {
  detector_id = aws_guardduty_detector.this.id
  name        = "EKS_RUNTIME_MONITORING"
  status      = "ENABLED"

  additional_configuration {
    name   = "EKS_ADDON_MANAGEMENT"
    status = "ENABLED"
  }
}

###############################################
# Organization Configuration
# - GuardDuty を組織アカウントに自動有効化する設定です。
# - auto_enable_organization_members は new/existing すべてのメンバーを対象とするかを制御します。
###############################################
resource "aws_guardduty_organization_configuration" "this" {
  detector_id                      = aws_guardduty_detector.this.id
  auto_enable_organization_members = var.auto_enable_members
}

###############################################
# Organization Features（追加設定不要分）
# - 上記 basic_features と同じ機能を組織メンバーにも自動有効化します。
###############################################
resource "aws_guardduty_organization_configuration_feature" "basic" {
  for_each    = toset(local.basic_features)
  detector_id = aws_guardduty_detector.this.id
  name        = each.value
  auto_enable = var.auto_enable_members
}

###############################################
# Organization Feature（EKS Runtime Monitoring）
# - EKS Runtime Monitoring を組織メンバーにも自動有効化します。
# - additional_configuration で Add-on 管理を有効化します。
###############################################
resource "aws_guardduty_organization_configuration_feature" "eks_runtime_monitoring" {
  detector_id = aws_guardduty_detector.this.id
  name        = "EKS_RUNTIME_MONITORING"
  auto_enable = var.auto_enable_members

  additional_configuration {
    name        = "EKS_ADDON_MANAGEMENT"
    auto_enable = var.auto_enable_members
  }
}

