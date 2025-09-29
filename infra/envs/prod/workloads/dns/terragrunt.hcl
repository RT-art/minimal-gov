include "root" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../../../modules/network/route53_private_zone"
}

dependency "vpc" {
  config_path = "../network/vpc"

  mock_outputs = {
    vpc_id = "vpc-00000000000000000"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs_merge_with_state           = true
}

dependency "alb" {
  config_path = "../alb"

  # Plan/validate 時はモック値を使用
  mock_outputs = {
    alb_dns_name = "internal-minimal-gov-prod-alb-123456.ap-northeast-1.elb.amazonaws.com"
    alb_zone_id  = "Z14GRHDCWA56QT"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
  mock_outputs_merge_with_state           = true
}

inputs = {
  app_name      = "minimal-gov-workloads"
  vpc_id        = dependency.vpc.outputs.vpc_id
  force_destroy = true
  records = [
    # ALB (alias)
    {
      name = "app"
      type = "A"
      alias = {
        # ALB から取得（dependency 経由）
        name    = dependency.alb.outputs.alb_dns_name
        zone_id = dependency.alb.outputs.alb_zone_id
      }
    }
  ]
}
