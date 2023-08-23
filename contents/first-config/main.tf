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
}

resource "aws_instance" "app_server" {
  ami           = "ami-830c94e3"
  instance_type = var.sizeType
  tags = {
    Name = "myvm"
  }
}

