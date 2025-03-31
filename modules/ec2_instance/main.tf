data "aws_ami" "amazon_linux_latest" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [var.module_ami_name_filter]
  }
}

data "aws_eip" "rt_eip" {
  filter {
    name   = "tag:Name"
    values = ["rt-practice-eip"]
  }
}

resource "aws_eip_association" "eip_assoc" {
  instance_id   = aws_instance.rt-practice-terraform.id
  allocation_id = data.aws_eip.rt_eip.id
}

resource "aws_instance" "rt-practice-terraform" {
  ami                         = data.aws_ami.amazon_linux_latest.id #amiの名前変更
  instance_type               = var.module_instance_type
  subnet_id                   = var.module_subnet_id
  vpc_security_group_ids      = [var.module_security_group_id]
  associate_public_ip_address = false # EIPを使うため、パブリックIPは割り当てない
  key_name                    = var.module_instance_key_name
  user_data = templatefile("setup-docker.sh.tpl", {
    docker_image_name = var.module_docker_image_name
  })

  tags = {
    Name = "rt-practice-terraform"
  }
}