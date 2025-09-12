terraform {
  backend "s3" {
    bucket       = "minimal-gov-dev-backend-tfstate-ap-northeast-1-351277498040"
    key          = "state/dns/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true
  }
}
