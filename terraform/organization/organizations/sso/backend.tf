terraform {
  backend "s3" {
    bucket       = ""
    key          = "state/sso/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true
  }
}