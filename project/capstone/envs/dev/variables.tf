variable "env" {
  type    = string
  default = "dev"
}

variable "azure_location" {
  type    = string
  default = "eastus"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vnet_cidr" {
  type    = string
  default = "10.10.0.0/16"
}

variable "subnets" {
  type = map(string)
  default = {
    web = "10.10.1.0/24"
    app = "10.10.2.0/24"
    db  = "10.10.3.0/24"
  }
}

variable "admin_ssh_public_key" {
  type        = string
  description = "Contents of your ~/.ssh/id_rsa.pub."
}
