terraform {
  backend "s3" {
    bucket  = ""
    key     = "state/organization/terraform.tfstate"
    region  = "ap-northeast-1"
    encrypt = true
  }
}