data "aws_partition" "current" {}

locals {
  # AWS Foundational Security Best Practices v1.0.0
  securityhub_fsbp_arn = "arn:${data.aws_partition.current.partition}:securityhub:${var.region}::standards/aws-foundational-security-best-practices/v/1.0.0"

  # CIS AWS Foundations Benchmark v1.4.0
  securityhub_cis_arn = "arn:${data.aws_partition.current.partition}:securityhub:${var.region}::standards/cis-aws-foundations-benchmark/v/1.4.0"
}
########################
# GuardDuty
########################

resource "aws_guardduty_detector" "this" {
  enable = true
}
resource "aws_guardduty_detector_feature" "this" {
  for_each = toset(var.guardduty_features)

  detector_id = aws_guardduty_detector.this.id
  name        = each.value
  status      = "ENABLED"
}

resource "aws_guardduty_organization_configuration" "this" {
  detector_id                      = aws_guardduty_detector.this.id
  auto_enable_organization_members = "ALL"
}

resource "aws_guardduty_organization_configuration_feature" "this" {
  for_each = toset(var.guardduty_features)

  detector_id = aws_guardduty_detector.this.id
  name        = each.value
  auto_enable = "ALL"
  depends_on  = [aws_guardduty_organization_configuration.this]
}

########################
# Security Hub
########################

resource "aws_securityhub_account" "this" {}

resource "aws_securityhub_organization_configuration" "central" {
  organization_configuration { configuration_type = "CENTRAL" }
  auto_enable           = true
  auto_enable_standards = "DEFAULT"
  depends_on            = [aws_securityhub_account.this]
}
resource "aws_securityhub_standards_subscription" "fsbp" {
  standards_arn = local.securityhub_fsbp_arn
  depends_on    = [aws_securityhub_account.this]
}

resource "aws_securityhub_standards_subscription" "cis" {
  standards_arn = local.securityhub_cis_arn
  depends_on    = [aws_securityhub_account.this]
}

resource "aws_securityhub_finding_aggregator" "this" {
  linking_mode = "ALL_REGIONS"
  depends_on   = [aws_securityhub_account.this]
}

########################
# AWS Config Aggregator
########################

resource "aws_config_configuration_aggregator" "org" {
  name = var.config_aggregator_name

  organization_aggregation_source {
    role_arn    = aws_iam_role.config_aggregator_role.arn
    all_regions = true
  }
      depends_on  = [aws_iam_role_policy_attachment.config_aggregator_attach]

}
resource "aws_iam_role" "config_aggregator_role" {
  name = var.config_aggregator_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "config.amazonaws.com" }
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "config_aggregator_attach" {
  role       = aws_iam_role.config_aggregator_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}


########################
# CloudTrail
########################

module "org_cloudtrail" {
  source = "../../modules/cloudtrail"

  trail_name            = var.trail_name
  is_organization_trail = true
  multi_region_trail    = true
  enable_kms_encryption = var.enable_kms_encryption
  enable_logging        = var.enable_logging
  tags                  = var.tags
}
