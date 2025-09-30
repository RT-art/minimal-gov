#############################################
# Data: Default AL2023 AMI (if ami_id not provided)
#############################################
data "aws_ssm_parameter" "al2023_ami" {
  count = var.ami_id == null ? 1 : 0
  name  = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

locals {
  ami_id = var.ami_id != null ? var.ami_id : (length(data.aws_ssm_parameter.al2023_ami) > 0 ? data.aws_ssm_parameter.al2023_ami[0].value : null)
}

#############################################
# Security Group
#############################################
module "sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.name}-sg"
  description = "SG for ${var.name}"
  vpc_id      = var.vpc_id

  # No inbound needed (use SSM)
  ingress_rules      = []
  egress_rules       = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]

  tags = merge({ Name = "${var.name}-sg" }, var.tags)
}

#############################################
# IAM Role for SSM
#############################################
data "aws_iam_policy" "ssm_core" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role" "this" {
  name = "${var.name}-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.this.name
  policy_arn = data.aws_iam_policy.ssm_core.arn
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name}-profile"
  role = aws_iam_role.this.name
}

#############################################
# EC2 Instance
#############################################
resource "aws_instance" "this" {
  ami                         = local.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [module.sg.security_group_id]
  iam_instance_profile        = aws_iam_instance_profile.this.name
  associate_public_ip_address = false

  tags = merge({ Name = var.name }, var.tags)
}

output "instance_id" {
  value = aws_instance.this.id
}

output "security_group_id" {
  value = module.sg.security_group_id
}

