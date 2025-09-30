include "root" {
  path = find_in_parent_folders("env.hcl")
}

terraform {
  source = "../../../../modules/compute/ecr"
}

inputs = {
  # Align ECR repo name with ECS image path: <acct>.dkr.ecr.<region>.amazonaws.com/<app_name>:<tag>
  repository_name         = "minimal-gov"
  repository_force_delete = true
}

