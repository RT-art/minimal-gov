output "oidc_provider_arn" {
  value = module.github_oidc.oidc_provider_arn
}

output "plan_role_name" {
  value = module.plan_role.iam_role_name
}

output "plan_role_arn" {
  value = module.plan_role.iam_role_arn
}

output "apply_role_name" {
  value = module.apply_role.iam_role_name
}

output "apply_role_arn" {
  value = module.apply_role.iam_role_arn
}
