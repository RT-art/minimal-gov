terraform {
  backend "s3" {
    bucket       = "minimal-gov-dev-backend-tfstate-ap-northeast-1-351277498040"
    key          = "state/api/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true
  }
}
