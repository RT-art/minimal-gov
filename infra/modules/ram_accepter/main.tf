###############################################
# RAM Resource Share Accepter
###############################################
resource "aws_ram_resource_share_accepter" "this" {
  share_arn = var.share_arn
}
