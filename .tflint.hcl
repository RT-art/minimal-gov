plugin "aws" {
  enabled = true
  version = "0.43.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

config {
  module = true
}

aws_region = "ap-northeast-1"
