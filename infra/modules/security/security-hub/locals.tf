###############################################
# 事前計算とタグ
###############################################
data "aws_caller_identity" "current" {}

locals {
  # セキュリティハブ関連リソースの命名を一元化
  securityhub_resource_name = "${var.app_name}-${var.env}-securityhub"

  # 共通タグを集約 (アプリ名・環境名を含める)
  merged_tags = merge(
    {
      Application = var.app_name
      Environment = var.env
      Name        = local.securityhub_resource_name
      ManagedBy   = "terraform"
    },
    var.tags,
  )

  # 委任管理者アカウント ID が未指定の場合は実行中のアカウントを利用
  delegated_admin_account_id = coalesce(
    var.delegated_admin_account_id,
    data.aws_caller_identity.current.account_id,
  )

  # 特定リージョンモード以外では空リストを渡す
  normalized_finding_aggregator_regions = (
    var.finding_aggregator_enabled && contains([
      "ALL_REGIONS_EXCEPT_SPECIFIED",
      "SPECIFIED_REGIONS",
    ], var.finding_aggregator_linking_mode)
  ) ? var.finding_aggregator_regions : []

  # 入力値を大文字に正規化してリソースへ渡す
  normalized_auto_enable_standards        = upper(var.organization_auto_enable_standards)
  normalized_configuration_type           = upper(var.organization_configuration_type)
  is_central_configuration                = var.enable_organization_admin && local.normalized_configuration_type == "CENTRAL"
  should_configure_organization_resources = var.enable_organization_admin
}
