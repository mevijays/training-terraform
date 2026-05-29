variable "name" {
  type        = string
  description = "Base name for the network (e.g., novapay-dev)."
}

variable "address_space" {
  type        = list(string)
  description = "VNet address space."
  validation {
    condition     = length(var.address_space) > 0
    error_message = "address_space must contain at least one CIDR."
  }
}

variable "subnets" {
  type        = map(string)
  description = "Map of subnet name to CIDR."
}

variable "resource_group_name" { type = string }
variable "location"            { type = string }

variable "tags" {
  type    = map(string)
  default = {}
}
