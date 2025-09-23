variable "peering_connection_id" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}

resource "aws_vpc_peering_connection_accepter" "this" {
  vpc_peering_connection_id = var.peering_connection_id
  auto_accept               = true
  tags = merge(var.tags, { Name = "network-to-workload" })
}

output "peering_connection_id" { value = aws_vpc_peering_connection_accepter.this.id }
