###############################################
# Minimal Gov: CI OIDC Deploy module
#
# この module は CI/CD パイプライン（GitHub Actions または
# CodePipeline など）から AWS へのデプロイを行うための IAM
# ロールを作成します。
#
# 作成される主なリソース:
# - (オプション) GitHub Actions 用 OIDC プロバイダ
# - デプロイ用 IAM ロール（ECR への Push、ECS UpdateService、
#   SSM PutParameter 権限を付与）
#
# 設計方針:
# - 可能な限りシンプルなロジック
# - セキュアな既定値の有効化
# - 上位モジュールが利用する最小限の出力
###############################################

###############################################
# GitHub OIDC プロバイダ (必要な場合のみ作成)
###############################################
resource "aws_iam_openid_connect_provider" "github" {
  count = var.github_org != null && var.github_repo != null ? 1 : 0

  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # GitHub Actions の公開証明書のフィンガープリント
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

###############################################
# Assume Role ポリシーの定義
###############################################
data "aws_iam_policy_document" "assume" {
  # GitHub OIDC からのアクセス許可
  dynamic "statement" {
    for_each = var.github_org != null && var.github_repo != null ? [1] : []
    content {
      effect  = "Allow"
      actions = ["sts:AssumeRoleWithWebIdentity"]
      principals {
        type        = "Federated"
        identifiers = [aws_iam_openid_connect_provider.github[0].arn]
      }
      condition {
        test     = "StringEquals"
        variable = "token.actions.githubusercontent.com:aud"
        values   = ["sts.amazonaws.com"]
      }
      condition {
        test     = "StringLike"
        variable = "token.actions.githubusercontent.com:sub"
        values   = ["repo:${var.github_org}/${var.github_repo}:*"]
      }
    }
  }

  # AWS 内のプリンシパルからのアクセス許可
  dynamic "statement" {
    for_each = length(var.trusted_principal_arns) > 0 ? [1] : []
    content {
      effect  = "Allow"
      actions = ["sts:AssumeRole"]
      principals {
        type        = "AWS"
        identifiers = var.trusted_principal_arns
      }
    }
  }
}

###############################################
# デプロイ用 IAM ロール
###############################################
resource "aws_iam_role" "this" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.assume.json

  # デプロイに必要な最低限の権限をインラインポリシーで付与
  inline_policy {
    name   = "deploy"
    policy = data.aws_iam_policy_document.deploy.json
  }

  tags = var.tags
}

###############################################
# デプロイ権限ポリシー
###############################################
data "aws_iam_policy_document" "deploy" {
  statement {
    sid    = "ECRPush"
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:BatchGetImage",
      "ecr:DescribeImages"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "ECSDeploy"
    effect = "Allow"
    actions = [
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService"
    ]
    resources = ["*"]
  }

  statement {
    sid       = "SSMPutParameter"
    effect    = "Allow"
    actions   = ["ssm:PutParameter"]
    resources = ["arn:aws:ssm:*:*:parameter/*"]
  }
}

###############################################
# End of module
###############################################
