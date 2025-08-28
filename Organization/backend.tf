terraform {
  backend "s3" {
    bucket         = "secure-backend-s3-tfstate-ap-northeast-1-911167886978"
    key            = "organization/terraform.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    use_lockfile   = true
  }
}