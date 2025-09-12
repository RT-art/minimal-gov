data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "minimal-gov-dev-backend-tfstate-ap-northeast-1-351277498040"
    key    = "state/vpc/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "api" {
  backend = "s3"
  config = {
    bucket = "minimal-gov-dev-backend-tfstate-ap-northeast-1-351277498040"
    key    = "state/api/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

module "svc_dns" {
  source    = "../../../../modules/route53-phz-service"
  zone_name = var.zone_name
  vpc_id    = data.terraform_remote_state.vpc.outputs.vpc_id
  records = [{
    name          = var.record_name
    type          = "A"
    alias_zone_id = data.terraform_remote_state.api.outputs.alb_zone_id
    alias_name    = data.terraform_remote_state.api.outputs.alb_dns_name
  }]
  tags = var.tags
}
