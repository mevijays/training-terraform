locals {
  vpc_cidr_block    = "192.168.1.0/24"
  subnet_cidr_block = "192.168.1.0/26"
  dev_region        = "us-west-2"
  subnet_az         = var.subnet_az
  instance_size     = "t3.small"
}