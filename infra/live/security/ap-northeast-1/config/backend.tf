terraform {
  backend "s3" {
    bucket       = "minimal-gov-sec-backend-tfstate-ap-northeast-1-454842420215"
    key          = "state/config/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true
  }
}
