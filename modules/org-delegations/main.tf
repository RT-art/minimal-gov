###############################################
# Minimal Gov: Organization Delegations module
#
# This module registers a central security account as the delegated
# administrator for organization-wide security services. By
# designating a single account, we can manage GuardDuty, Security Hub,
# and CloudTrail centrally while keeping member accounts minimal.
#
# Resources created:
# - GuardDuty Organization Admin Account (optional)
# - Security Hub Organization Admin Account (optional)
# - CloudTrail Organization Delegated Admin Account (optional)
#
# Design guidelines:
# - Keep logic straightforward and thoroughly documented
# - Enable secure defaults (delegations enabled unless explicitly
#   disabled)
# - Expose no outputs because delegation has side effects only
###############################################

###############################################
# Terraform settings and provider configuration
###############################################
terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.9"
    }
  }
}

# Provider configuration uses variables for region and tagging so that
# all resources inherit consistent metadata.
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Application = var.app_name
      Environment = var.env
      ManagedBy   = "Terraform"
      Region      = var.region
    }
  }
}

###############################################
# GuardDuty delegated administrator
# - Registers the security account as the delegated admin for
#   GuardDuty. This allows the security account to centrally manage
#   GuardDuty across all organization accounts.
# - Creation is controlled by enable_guardduty.
###############################################
resource "aws_guardduty_organization_admin_account" "this" {
  count            = var.enable_guardduty ? 1 : 0
  admin_account_id = var.security_account_id
}

###############################################
# Security Hub delegated administrator
# - Similar to GuardDuty, this enables the security account to manage
#   Security Hub findings and settings for the entire organization.
# - Controlled by enable_securityhub.
###############################################
resource "aws_securityhub_organization_admin_account" "this" {
  count            = var.enable_securityhub ? 1 : 0
  admin_account_id = var.security_account_id
}

###############################################
# CloudTrail delegated administrator
# - Grants the security account authority to manage organization-wide
#   CloudTrail trails. Useful for centralized audit log configuration.
# - Controlled by enable_cloudtrail.
###############################################
resource "aws_cloudtrail_organization_delegated_admin_account" "this" {
  count      = var.enable_cloudtrail ? 1 : 0
  account_id = var.security_account_id
}

