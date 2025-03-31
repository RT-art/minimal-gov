resource "aws_security_group" "security-group-practice-terraform" {
  vpc_id = var.module_vpc_id
  tags = {
    Name = "security-group-practice-terraform"
  }
}

resource "aws_security_group_rule" "http-ingress-rule" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security-group-practice-terraform.id
}

resource "aws_security_group_rule" "ssh-ingress-rule" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security-group-practice-terraform.id
}

resource "aws_security_group_rule" "https-ingress-rule" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security-group-practice-terraform.id
}
#セキュリティグループのアウトバウンドを未設定にしてたらlinuxコマンド反応しなかったため、全てのアウトバウンドを許可するように変更
resource "aws_security_group_rule" "all-egress-rule" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.security-group-practice-terraform.id
}