variable "name"                { type = string }
variable "resource_group_name" { type = string }
variable "location"            { type = string }

variable "vnet_id" {
  type    = string
  default = null
  description = "Optional: VNet to attach diagnostic settings to."
}

variable "tags" {
  type    = map(string)
  default = {}
}
