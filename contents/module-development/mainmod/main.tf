resource "random_string" "this" {
  special = false
  length  = 6
  lower   = true
  upper   = false
}

resource "aws_key_pair" "main" {
  key_name   = "${var.key_name}-${random_string.this.result}"
  public_key = var.public_key
}
locals {
  map_ports = {
    ssh = {
      f_port     = 22
      protocol   = "tcp"
      cidr_block = ["0.0.0.0/0"]
    }
    mysql = {
      f_port     = 3306
      protocol   = "tcp"
      cidr_block = ["192.168.1.0/24"]
    }
  }
}
resource "aws_security_group" "main" {
  name   = "${var.key_name}-${random_string.this.result}"
  vpc_id = var.vpc_id
  dynamic "ingress" {
    for_each = local.map_ports
    content {
      from_port   = ingress.value.f_port
      to_port     = ingress.value.f_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_block
    }
  }

}
resource "aws_instance" "main" {
  instance_type = var.vm_type
  ami           = var.ami_id
  availability_zone = var.availability_zone
  user_data = var.user_data
  key_name = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.main.id]
  subnet_id = var.ec2_subnet
}