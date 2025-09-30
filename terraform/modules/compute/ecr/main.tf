#############################################
# ECR
#############################################
module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 3.1"

  repository_name                 = var.repository_name
  repository_image_tag_mutability = "IMMUTABLE"

  # ライフサイクル（最後の10イメージ以外を削除）
  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = { type = "expire" }
      }
    ]
  })

  tags = merge(
    {
      Name = "${var.app_name}-${var.env}-ecr"
    },
    var.tags
  )
}
