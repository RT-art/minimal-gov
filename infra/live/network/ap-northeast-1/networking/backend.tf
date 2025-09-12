terraform {
  backend "s3" {
    bucket       = "minimal-gov-network-backend-tfstate-ap-northeast-1-653502182074"
    key          = "state/network/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true
  }
}
