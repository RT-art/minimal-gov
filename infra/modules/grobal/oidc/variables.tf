variable "region" {
  type        = string
  description = "AWS region"
}

variable "app_name" {
  type        = string
  description = "Application name"
}

variable "env" {
  type        = string
  description = "Environment name (dev/stg/prod)"
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "github_org" {
  default = "YOUR_GITHUB_ORG"
}

variable "github_repo" {
  default = "YOUR_REPO"
}

variable "managed_policy_arns" {
  description = "GitHub ActionsロールにアタッチするIAM管理ポリシーARNのリスト"
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/PowerUserAccess",
    "arn:aws:iam::aws:policy/AWSOrganizationsFullAccess",
    "arn:aws:iam::aws:policy/IAMFullAccess"
  ]
}
