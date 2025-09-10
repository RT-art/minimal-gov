###############################################
# Minimal Gov: Security Hub module
#
# このモジュールは AWS Security Hub を組織単位で有効化するための
# 最小構成を提供します。主な機能:
# - セキュリティアカウントで Security Hub を有効化
# - Organization 成員アカウントを自動的に有効化
# - AWS Foundational Security Best Practices への購読（任意）
# - 全リージョンのファインディングを集約する Finding Aggregator の作成
#
# 設計指針:
# - ロジックは単純明快に保ち、読みやすさを最優先
# - セキュリティ既定値（組織への自動有効化等）はデフォルトで有効
# - 出力は上位モジュールが依存する最小限（Aggregator ARN のみ）
###############################################

###############################################
# Security Hub Account
# - 現在のアカウントで Security Hub を有効化します。
# - enable_* のフラグは存在しないため、リソースを作成するだけで有効化されます。
###############################################
resource "aws_securityhub_account" "this" {}

###############################################
# Organization Configuration
# - auto_enable が true の場合、組織の新規/既存アカウントに
#   Security Hub を自動的に有効化します。
###############################################
resource "aws_securityhub_organization_configuration" "this" {
  auto_enable = var.auto_enable_members
}

###############################################
# Standards Subscription (AFSBP)
# - AWS Foundational Security Best Practices への購読を制御します。
# - enable_afsbp が true の場合のみリソースを作成します。
###############################################
resource "aws_securityhub_standards_subscription" "afsbp" {
  count         = var.enable_afsbp ? 1 : 0
  standards_arn = "arn:aws:securityhub:::standards/aws-foundational-security-best-practices/v/1.0.0"
}

###############################################
# Finding Aggregator
# - 複数リージョンのファインディングを集約します。
# - linking_mode を指定して集約方法を制御します。
###############################################
resource "aws_securityhub_finding_aggregator" "this" {
  linking_mode = var.linking_mode
}

