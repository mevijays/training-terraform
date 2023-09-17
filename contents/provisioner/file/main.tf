terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.16.1"
    }
  }
}

provider "aws" {
  region = "us-west-2"
}

data "aws_vpc" "main" {
  default = true
}
locals {
  inbound_rules = [
    {
      port = 22
      protocol = "tcp"
      cidr = ["192.168.1.0/24"]
    },
    {
      port  = 80
      protocol = "tcp"
      cidr = ["0.0.0.0/0"]
    },
    {
      port = 123
      protocol = "udp"
      cidr = ["192.168.10.0/24"]
    }
  ]
}


resource "aws_security_group" "main" {
  name   = "vpc-file"
  vpc_id = data.aws_vpc.main.id
  dynamic "ingress" {
    for_each = local.inbound_rules
    content {
      from_port = ingress.value.port
      to_port = ingress.value.port
      protocol = ingress.value.protocol
      cidr_blocks = ingress.value.cidr
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc-file"
  }
}

resource "aws_key_pair" "main" {
  key_name   = "cloud-key"
  public_key = file("ec2-key.pub")
}
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
  owners = ["099720109477"] # Canonical
}
locals {
  key_pub   = file("ec2-key")
  size      = "t2.micro"
  user_data = <<-EOF
  #!/bin/bash
  sudo apt update -y
  sudo apt install apache2 -y
  sudo systemctl enable apache2
  sudo systemctl start apache2
  echo '<h1>Hello class from Terraform</h1>' >> /var/www/html/index.html
  echo '<hr>' >> /var/www/html/index.html
  git clone https://github.com/mevijays/training-terraform
  sudo mv training-terraform /var/www/html/
  EOF
}
resource "aws_instance" "main" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = local.size
  security_groups = [aws_security_group.main.name]
  key_name        = aws_key_pair.main.key_name
  user_data       = local.user_data
  provisioner "remote-exec" {
    inline = [ 
        "echo yourselfself >> file1",
        "hostname"
     ]
   connection {
           host        = self.public_dns
      type        = "ssh"
      user        = "ubuntu"
      private_key = local.key_pub
    }
   }
  
  provisioner "local-exec" {
    command = "echo this-is-private-ip-${self.private_ip} >> ec2-outputs.txt"
  }
}

output "vm_public_ip" {
  value = aws_instance.main.public_dns
}
