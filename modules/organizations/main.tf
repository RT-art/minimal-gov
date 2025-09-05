# AWS Organization本体作成
resource "aws_organizations_organization" "this" {
  feature_set                   = "ALL" # 組織の全機能を有効化（おまじない・とりあえずALLで良い）
  enabled_policy_types          = tolist(var.enabled_policy_types)    # なんのポリシー(scp、tagポリシー等)を有効化するか
  aws_service_access_principals = var.aws_service_access_principals # サービスアクセスを有効化するリソース指定（guardduty,configなど、組織内で一元管理したいリソース）

  # Organizationの削除はterraformでは行えないようにする
  lifecycle {
    prevent_destroy = true
  }
}

# OU作成
# 下記のような、標準的なベストプラクティスなOU構成を作成
# Root
# ├─ Security  # 組織のセキュリティリソースを一元管理する
# ├─ Workloads  # アプリケーションが動作するメインの環境群
# │   ├─ Prod # 本番環境
# │   └─ Dev # 開発環境
# ├─ Sandbox  # 開発用に自由に使えるアカウントを配置
# └─ Suspended  # 利用停止中のアカウントを配置

# ループで作成する方法もあるが、式の複雑化による可読性低下を避けるために一つずつ作成
# securityアカウント環境
resource "aws_organizations_organizational_unit" "security" {
  name      = "Security"
  parent_id = local.root_id
  tags      = var.tags
  lifecycle { prevent_destroy = true }
}

# メインとなるワークロードのアカウント環境
resource "aws_organizations_organizational_unit" "workloads" {
  name      = "Workloads"
  parent_id = local.root_id
  tags      = var.tags
  lifecycle { prevent_destroy = true }
}

# workloads配下にProd, Devを作成
resource "aws_organizations_organizational_unit" "prod" {
  name      = "Prod"
  parent_id = aws_organizations_organizational_unit.workloads.id
  tags      = var.tags
  lifecycle { prevent_destroy = true }
}

# workloads配下にProd, Devを作成
resource "aws_organizations_organizational_unit" "dev" {
  name      = "Dev"
  parent_id = aws_organizations_organizational_unit.workloads.id
  tags      = var.tags
  lifecycle { prevent_destroy = true }
}

# sandboxアカウント環境
resource "aws_organizations_organizational_unit" "sandbox" {
  name      = "Sandbox"
  parent_id = local.root_id
  tags      = var.tags
  lifecycle { prevent_destroy = true }
}

# suspendedアカウント環境
resource "aws_organizations_organizational_unit" "suspended" {
  name      = "Suspended"
  parent_id = local.root_id
  tags      = var.tags
  lifecycle { prevent_destroy = true }
}

# Securityアカウントを作成
resource "aws_organizations_account" "security" {
  name      = var.security_account_name
  email     = var.security_account_email
  role_name = OrganizationAccountAccessRole # 作られたアカウントに管理アカウントがアクセスするためのロール名 標準ではOrganizationAccountAccessRole
  parent_id = aws_organizations_organizational_unit.security.id # どこのouに所属させるかを指定
  tags      = merge(var.tags, { AccountType = "Security" }) # 固定タグ群にAccountType=Securityを追加

  lifecycle { prevent_destroy = true }

  timeouts { create = "2h" } # アカウント作成は時間がかかるのでタイムアウトを2時間に延長
}

# メンバーアカウントを作成
# 変数（mapでアカウント情報を定義）で与えられたアカウント情報を元にアカウントを作成
resource "aws_organizations_account" "members" {
  for_each  = var.member_accounts
  name      = each.value.name
  email     = each.value.email
  role_name = OrganizationAccountAccessRole
  parent_id = local.ou_ids[lower(each.value.ou)] # mapからou名を取得
  
  tags = merge(
    var.tags,
    { AccountType = each.value.tags } # 固定タグ群にアカウント固有のtagを追加
  )

  lifecycle { prevent_destroy = true }
  timeouts  { create = "2h" }
}

# Securityアカウントを委任管理者に登録
# 変数で書いたサービスをループで登録
resource "aws_organizations_delegated_administrator" "security_delegate" {
  for_each          = var.delegated_services
  account_id        = aws_organizations_account.security.id
  service_principal = each.key # set(string)なのでkeyは値そのもの
}

module "scp" {
  source = "../scp"

  allowed_regions = var.allowed_regions
  tags            = var.tags

  targets = {
    root_id     = local.org_root_id
    security_ou = local.ou_ids[lower(var.security_ou_name)]
    workloads   = local.ou_ids[lower(var.workloads_ou_name)]
    prod        = local.ou_ids[lower(var.prod_ou_name)]
    dev         = local.ou_ids[lower(var.dev_ou_name)]
    sandbox     = local.ou_ids[lower(var.sandbox_ou_name)]
    suspended   = local.ou_ids[lower(var.suspended_ou_name)]
  }

  attach_map = {
    deny_root                 = ["root_id"]
    deny_leaving_org          = ["root_id"]
    deny_unapproved_regions   = ["root_id"]
    deny_disable_sec_services = ["prod", "dev", "sandbox"]
    deny_all_suspended        = ["suspended"]
  }

  depends_on = [aws_organizations_organization.this]
}
