terraform {
  backend "s3" {
    bucket       = "aws-remotebackend-bootstrap-tfstate-ap-northeast-1-653502182074"
    key          = "state/organization/terraform.tfstate"
    region       = "ap-northeast-1"
    encrypt      = true
  }
}