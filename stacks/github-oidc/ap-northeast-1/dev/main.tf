module "github_oidc" {
  source = "../../../../modules/platform/github-oidc"

  env              = var.env
  app_name         = var.app_name
  region           = var.region
  full_repository  = var.repo
  allowed_branches = var.branches

  # とりあえずPowerUser
  managed_policy_arns = ["arn:aws:iam::aws:policy/PowerUserAccess"]

  tags = {
    Stack = "github-oidc"
  }
}
