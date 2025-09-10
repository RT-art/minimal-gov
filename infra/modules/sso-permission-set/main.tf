###############################################
# Minimal Gov: SSO Permission Set module
#
# この module は AWS IAM Identity Center (旧 AWS SSO) に
# Permission Set を作成し、指定された AWS マネージドポリシーを
# アタッチします。また、必要に応じて複数アカウント・ユーザ/グループ
# へ割り当てを行います。
#
# 主なリソース:
# - aws_ssoadmin_permission_set: Permission Set 本体
# - aws_ssoadmin_managed_policy_attachment: マネージドポリシーの付与
# - aws_ssoadmin_account_assignment: アカウントへの割当
################################################

# SSO インスタンス ARN を決定する。
# 入力が無ければ最初のインスタンスを自動検出する。
data "aws_ssoadmin_instances" "this" {}

locals {
  instance_arn = var.instance_arn != null && var.instance_arn != "" ? var.instance_arn : data.aws_ssoadmin_instances.this.arns[0]
}

###############################################
# Permission Set 本体
###############################################
resource "aws_ssoadmin_permission_set" "this" {
  name         = var.permission_set_name
  instance_arn = local.instance_arn

  # セッション継続時間を指定 (既定 8 時間)。
  session_duration = var.session_duration

  # 任意のタグを付与。上位で default_tags を設定していない場合にもタグ付け可能。
  tags = var.tags
}

###############################################
# マネージドポリシーの付与
###############################################
# 指定された各 AWS マネージドポリシーを Permission Set にアタッチする。
resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each           = toset(var.managed_policy_arns)
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this.arn
  managed_policy_arn = each.value
}

###############################################
# Permission Set のアカウント割当
###############################################
# 複数のアカウント / ユーザまたはグループへの割当を定義する。
# assignments 変数が空の場合、このリソースは作成されない。
resource "aws_ssoadmin_account_assignment" "this" {
  for_each = {
    for assignment in var.assignments :
    "${assignment.account_id}-${assignment.principal_type}-${assignment.principal_id}" => assignment
  }

  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this.arn
  principal_id       = each.value.principal_id
  principal_type     = each.value.principal_type
  target_id          = each.value.account_id
  target_type        = "AWS_ACCOUNT"
}

