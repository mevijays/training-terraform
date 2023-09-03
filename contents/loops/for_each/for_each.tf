terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
locals {
  instance_size   = "t2.micro"
  provider_region = "us-east-2"
  tag_name        = "myvm"
  image_ami_id    = "ami-05d251e0fc338590c"
}

provider "aws" {
  region = local.provider_region
}

data "aws_vpc" "vpc" {
  default = true
}
data "aws_subnets" "example" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

// Example 1
resource "aws_instance" "app_server" {
  for_each      = toset(data.aws_subnets.example.ids)
  ami           = local.image_ami_id
  instance_type = local.instance_size
  subnet_id     = each.key
  tags = {
    Name = local.tag_name
  }
}



//---bellow is variable type list of object but with for_each it does not support. instead it works with dynamic block.
/*
variable "subnetobject" {
  type = list(object({
    CIDR = string
    AZ = string 
  }))
  default = [ {
    CIDR = "10.0.4.0/24"
    AZ = "us-east-2a"
  },
  {
    CIDR = "10.0.5.0/24"
    AZ = "us-east-2b"
  } ]
}
*/

//Example 2

variable "subnets" {
  type = map(string)
  default = {
    "us-east-2a" = "10.0.1.0/24"
    "us-east-2b" = "10.0.2.0/24"
    "us-east-2c" = "10.0.3.0/24"
  }
}

resource "aws_subnet" "example" {
  for_each          = var.subnets
  vpc_id            = data.aws_vpc.vpc.id
  cidr_block        = each.value
  availability_zone = each.key
}