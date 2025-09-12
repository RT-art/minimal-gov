env      = "dev"
app_name = "minimal-gov-dev-ecr"
region   = "ap-northeast-1"

tags = {
  Project = "minimal-gov"
}

name                = "app"
keep_last_images    = 10
pull_principal_arns = []
