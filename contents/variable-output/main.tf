terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.13.0"
    }
  }
  required_version = ">= 1.5.0"
}
// provider block 
provider "aws" {
  region = local.aws_region
}
//Local block - same as variable but aggregated and used in-configuration file.
locals {
  instance_size = "t3.small"
  aws_region    = "us-west-2"
}

// variable block
variable "ec2_ami" {
  type = string
  default = "ami-002829755fa238bfa"
}

// resource block
resource "aws_instance" "main" {
  ami           = var.ec2_ami
  instance_type = local.instance_size
}
resource "aws_vpc" "main" {
  cidr_block = "192.168.1.0/24"
}

// Output block
output "my_vpc_id" {
  value = aws_vpc.main.id
}
output "my_vm_public_ip" {
  value = aws_instance.main.public_ip
}
output "my_vm_private_ip" {
  value = aws_instance.main.private_ip
}
output "instance_size" {
  value = local.instance_size
}
