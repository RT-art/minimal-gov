locals {
  inbound_subnet_ids = [for sn in ["ops-a", "ops-c"] : module.vpc.subnets[sn].id]
}