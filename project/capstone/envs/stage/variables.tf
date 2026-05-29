variable "env"            { type = string; default = "stage" }
variable "azure_location" { type = string; default = "eastus" }
variable "aws_region"     { type = string; default = "us-east-1" }
variable "vnet_cidr"      { type = string; default = "10.20.0.0/16" }

variable "subnets" {
  type = map(string)
  default = {
    web = "10.20.1.0/24"
    app = "10.20.2.0/24"
    db  = "10.20.3.0/24"
  }
}

variable "admin_ssh_public_key" { type = string }
