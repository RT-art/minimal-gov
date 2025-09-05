locals {

  root_id = aws_organizations_organization.this.roots[0].id

  ou_ids = {
       security  = aws_organizations_organizational_unit.security.id
       workloads = aws_organizations_organizational_unit.workloads.id
       prod      = aws_organizations_organizational_unit.prod.id
       dev       = aws_organizations_organizational_unit.dev.id
       sandbox   = aws_organizations_organizational_unit.sandbox.id
       suspended = aws_organizations_organizational_unit.suspended.id
     }
  
  member_tags = merge(var.tags, { AccountType = "Member" })
}
