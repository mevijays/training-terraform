terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
variable "sizeType" {
  type        = string
  default     = "t2.micro"
  description = "define a variable of ec2 t-shirt size"
}

provider "aws" {
  region     = "us-west-2"
  access_key = "AKIA4TZXDTTMNE5DRV6G"
  secret_key = "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"
}

resource "aws_instance" "app_server" {
  ami           = "ami-830c94e3"
  instance_type = var.sizeType
  tags = {
    Name = "myvm"
  }
}

