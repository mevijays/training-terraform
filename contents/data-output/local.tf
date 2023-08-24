terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
locals {
  instance_size = "t2.micro"
  provider_region = "us-east-2"
  tag_name = "myvm"
  image_ami_id = "ami-05d251e0fc338590c"
}

provider "aws" {
  region     = local.provider_region
}

resource "aws_instance" "app_server" {
  ami           = local.image_ami_id
  instance_type = local.instance_size
  tags = {
    Name = local.tag_name
  }
}
