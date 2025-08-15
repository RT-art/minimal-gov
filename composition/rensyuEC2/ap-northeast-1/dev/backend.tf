terraform {
  backend "s3" {
    bucket       = "remote-backend-s3-tfstate-ap-northeast-1-911167886978"
    key          = "rensyuEC2/ap-northeast-1/dev/terraform.tfstate"
    region       = "ap-northeast-1"
    use_lockfile = true
  }
}
