include {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../../modules/ram_accepter"
}

inputs = {
  share_arn = "arn:aws:ram:ap-northeast-1:854669817093:resource-share/697c0ab2-defd-4e33-8f22-050c015b5490"
}