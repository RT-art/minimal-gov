locals {
  role_name = "${var.app_name}-${var.env}-github-oidc"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = var.provider_url
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = var.thumbprints
  tags            = merge(var.tags, { Name = "github-oidc-provider" })
}

data "aws_iam_policy_document" "assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [for b in var.allowed_branches : "repo:${var.full_repository}:ref:refs/heads/${b}"]
    }
  }
}

resource "aws_iam_role" "this" {
  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.assume.json
  tags               = merge(var.tags, { Name = local.role_name })
}

resource "aws_iam_role_policy_attachment" "managed" {
  for_each   = toset(var.managed_policy_arns)
  role       = aws_iam_role.this.name
  policy_arn = each.value
}
