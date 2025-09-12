terraform {
  backend "s3" {
    bucket       = "minimal-gov-onprem-backend-tfstate-ap-northeast-1-653502182074"
    key          = "state/onprem/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true
  }
}
