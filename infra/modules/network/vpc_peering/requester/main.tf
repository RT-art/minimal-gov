variable "requester_vpc_id" { type = string }
variable "peer_vpc_id" { type = string }
variable "peer_owner_id" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}

resource "aws_vpc_peering_connection" "this" {
  vpc_id        = var.requester_vpc_id
  peer_vpc_id   = var.peer_vpc_id
  peer_owner_id = var.peer_owner_id
  auto_accept   = false

  tags = merge(var.tags, { Name = "network-to-workload" })
}

output "peering_connection_id" { value = aws_vpc_peering_connection.this.id }
