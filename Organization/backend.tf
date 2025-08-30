terraform {
  backend "s3" {
    bucket       = "aws-remotebackend-bootstrap-tfstate-ap-northeast-1-911167886978"
    key          = "organization/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
    use_lockfile = true
  }
}