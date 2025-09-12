module "centralized_flowlogs" {
  source = "./modules/centralized-flowlogs"

  log_group_name    = "/central/vpc-flow-logs"
  retention_in_days = 180
}