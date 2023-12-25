terraform {
  required_version = "~> 1.6.4" // the terraform binary version which can execute these configuration tf files
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.29.0"
    }
  }

  cloud {
    organization = "krlab"

    workspaces {
      name = "aws-ws"
    }
  }
}

locals {
  my_region = "us-east-2"
  ports = [80,22]
  map_ports = {
         ssh = {
            f_port = 22
            protocol = "tcp"
            cidr_block = ["0.0.0.0/0"]
         }
          mysql = {
            f_port = 3306
            protocol = "tcp"
            cidr_block = ["192.168.1.0/24"]
         }
  }
}
provider "aws" {
  region = local.my_region
}

data "aws_vpc" "this" {
  default = true
}
data "aws_subnets" "this" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }
}
data "aws_ami" "main" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server*"]
  }
}
resource "aws_key_pair" "main" {
  key_name   = "awskey"
  public_key = file("./aws-key.pub")
}

resource "aws_security_group" "main" {
  name = "mysg"
  vpc_id = data.aws_vpc.this.id
  dynamic "ingress" {
    for_each = local.map_ports
    content {
      from_port        = ingress.value.f_port
      to_port          = ingress.value.f_port
      protocol         = ingress.value.protocol
      cidr_blocks      = ingress.value.cidr_block
    }
  }
  /*
  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]  
  }
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]  
  }
  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]  
  }
  */
}
resource "aws_instance" "main" {
  ami           = data.aws_ami.main.id
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnets.this.ids[0]
  security_groups = [ aws_security_group.main.id ]
  user_data     = <<EOF
#!/bin/bash
sudo apt update 
sudo apt install apache2 -y
sudo systemctl enable apache2
sudo systemctl start apache2
EOF
  key_name      = aws_key_pair.main.key_name
  tags = { Name = "myvm", owner = "vijay"}
}

output "my_instance_public_ip" {
  value = "This is my ec2 public ip: - ${aws_instance.main.public_ip}"
}
