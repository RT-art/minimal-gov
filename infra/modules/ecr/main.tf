module "ecr_repo" {
  source  = "terraform-aws-modules/ecr/aws"
  version = ">= 1.0.0"

  repository_name                  = var.repository_name
  image_tag_mutability             = "IMMUTABLE"  
  scan_on_push                     = true         
  repository_read_write_access_arns = var.repository_read_write_access_arns

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = []
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = merge(
    {
      ManagedBy = "terraform"
    },
    var.extra_tags
  )
}
