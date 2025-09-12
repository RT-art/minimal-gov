output "zone_id" {
  description = "ID of the private hosted zone"
  value       = module.svc_dns.zone_id
}
