locals {
  plan_subjects = flatten([
    for r in var.allowed_repositories : concat(
      [for b in var.plan_branches  : "repo:${r}:ref:refs/heads/${b}"],
      var.allow_pull_request ? ["repo:${r}:pull_request"] : []
    )
  ])

  apply_subjects = flatten([
    for r in var.allowed_repositories : concat(
      [for b in var.apply_branches : "repo:${r}:ref:refs/heads/${b}"],
      var.apply_tag_pattern != null ? ["repo:${r}:ref:refs/tags/${var.apply_tag_pattern}"] : []
    )
  ])

  # state backend 用の ARN 整形
  state_bucket_arn_no_slash = var.state_bucket_arn == null ? null : replace(var.state_bucket_arn, "/*", "")
  state_bucket_objects_arn  = var.state_bucket_arn == null ? null : (
    endswith(var.state_bucket_arn, ":*") ? var.state_bucket_arn : "${var.state_bucket_arn}/*"
  )
}
