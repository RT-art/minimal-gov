########################################
# 1) Organizations 本体
########################################
resource "aws_organizations_organization" "this" {
  feature_set          = "ALL"
  enabled_policy_types = ["SERVICE_CONTROL_POLICY"] # 最小限: SCP だけ
}

# ルートIDを取る（OU/ポリシーの親で使う）
data "aws_organizations_organization" "current" {
  depends_on = [aws_organizations_organization.this]
}

locals {
  root_id = one(data.aws_organizations_organization.current.roots[*].id)
}

########################################
# 2) OU（セキュリティ/共有/本番）
########################################
resource "aws_organizations_organizational_unit" "ou" {
  for_each  = toset(var.ous)
  name      = each.key
  parent_id = local.root_id
}

########################################
# 3) アカウント（各 OU に1つずつ）
########################################
resource "aws_organizations_account" "acct" {
  for_each  = var.accounts
  name      = each.key         # 例: "security", "shared", "prod"
  email     = each.value.email # 実在メール必須
  parent_id = aws_organizations_organizational_unit.ou[each.value.ou].id
  role_name = "OrganizationAccountAccessRole" # 作成直後に乗るための既定ロール
  tags      = merge(var.default_tags, { "ou" = each.value.ou })
}

########################################
# 4) 最小 SCP: 許可リージョン以外を全面 Deny
#    （東京/大阪 だけを例示。必要に応じて編集）
########################################
resource "aws_organizations_policy" "allow_regions_only" {
  name = "allow-regions-only"
  type = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "DenyNotAllowedRegions"
        Effect   = "Deny"
        Action   = "*"
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = var.allowed_regions
          }
        }
      }
    ]
  })
}

resource "aws_organizations_policy_attachment" "attach_allow_regions" {
  policy_id = aws_organizations_policy.allow_regions_only.id
  target_id = local.root_id # ルート配下すべてに適用
}
