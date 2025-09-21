resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "this" {
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecr_repository_policy" "rw" {
  count      = length(var.repository_read_write_access_arns) > 0 ? 1 : 0
  repository = aws_ecr_repository.this.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "EcrReadWrite",
        Effect   = "Allow",
        Principal = { AWS = var.repository_read_write_access_arns },
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchDeleteImage"
        ]
      }
    ]
  })
}
