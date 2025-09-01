data "terraform_remote_state" "org" {
  backend = "s3"
  config = {
    bucket = var.org_state_bucket
    key    = var.org_state_key
    region = var.org_state_region
  }
}

# SSOユーザにはAdministratorAccessを固定で与える（実務では必ず最小権限）
# セッション有効期限は 8時間
resource "aws_ssoadmin_permission_set" "admin" {
  name             = "AdministratorAccess"
  instance_arn     = data.aws_ssoadmin_instances.main.arns[0]
  session_duration = "PT8H"
}
# ポリシーをアタッチ
resource "aws_ssoadmin_managed_policy_attachment" "admin_attach" {
  instance_arn       = data.aws_ssoadmin_instances.main.arns[0]
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
}

# 変数で渡された
resource "aws_ssoadmin_account_assignment" "admin_assign" {
  for_each = data.terraform_remote_state.org.outputs.member_account_ids

  instance_arn       = data.aws_ssoadmin_instances.main.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.admin.arn
  principal_type     = "USER"
  principal_id       = var.user_id   # Identity Center ユーザーID
  target_type        = "AWS_ACCOUNT"
  target_id          = each.value
}
