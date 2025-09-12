module "securityhub" {
  source              = "../../../../modules/security-securityhub"
  auto_enable_members = var.auto_enable_members
  enable_afsbp        = var.enable_afsbp
  linking_mode        = var.linking_mode
}
