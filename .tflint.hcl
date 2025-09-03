plugin "aws" {
  enabled = true
  version = "0.42.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

config {
  call_module_type = "local"
}

rule "terraform_deprecated_interpolation" {
  enabled  = true
  severity = "ERROR"
}

rule "terraform_unused_declarations" {
  enabled  = true
  severity = "WARNING"
}

rule "aws_instance_invalid_type" {
  enabled  = true
  severity = "ERROR"
}

