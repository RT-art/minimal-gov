#############################################
# ECR
#############################################
module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "~> 3.1"

  repository_name = "${var.app_name}-${var.env}-ecr"

  # タグ不変
  repository_image_tag_mutability = "IMMUTABLE"

  # プッシュ時スキャン
  repository_image_scanning_configuration = {
    scan_on_push = true
  }

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
  # ↑公式readmeを参考にjsonで

  # 読み書き許可を付与（readme参考に）
  repository_read_write_access_arns = var.repository_read_write_access_arns

  # 既定AES256 → KMS
  repository_encryption_type = var.repository_encryption_type # 例: KMS or AES256（既定 AES256）
  repository_kms_key         = var.repository_kms_key         # 例: "arn:aws:kms:ap-northeast-1:123456789012:key/xxxx"

  # destroy時にイメージ残ってても強制削除するか
  repository_force_delete = var.repository_force_delete # 既定はfalse

  # ecr読み取りしたいリソースを追加
  repository_read_access_arns = var.repository_read_access_arns # 例: CI等

  tags = merge(
    {
      Name = "${var.app_name}-${var.env}-ecr"
    },
    var.tags
  )
}
