terraform {
  backend "s3" {
    bucket       = ""
    key          = "state/ssouser/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true
  }
}