terraform {
  backend "s3" {
    bucket       = "minimal-gov-network-backend-tfstate-ap-northeast-1-854669817093"
    key          = "state/network/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true
  }
}