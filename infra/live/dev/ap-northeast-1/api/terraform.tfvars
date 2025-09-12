env      = "dev"
app_name = "minimal-gov-dev-api"
region   = "ap-northeast-1"

tags = {
  Project = "minimal-gov"
}

container_image   = "nginx:latest"
container_port    = 80
desired_count     = 1
task_cpu          = 256
task_memory       = 512
allowed_cidrs     = ["10.0.0.0/16"]
health_check_path = "/"
