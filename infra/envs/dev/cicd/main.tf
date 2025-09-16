module "iam_oidc" {
  source = "../../../../modules/oidc"

  github_org  = var.github_org
  github_repo = var.github_repo
}