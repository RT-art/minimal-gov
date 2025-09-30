terraform {
  required_version = ">= 1.11.3, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.14"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = merge(
      var.tags,
      {
        Environment = var.env
        Application = var.app_name
      }
    )
  }
}
