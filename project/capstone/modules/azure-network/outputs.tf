output "vnet_id" {
  value       = azurerm_virtual_network.this.id
  description = "VNet resource ID."
}

output "vnet_name" {
  value       = azurerm_virtual_network.this.name
  description = "VNet name."
}

output "subnet_ids" {
  value       = { for k, s in azurerm_subnet.this : k => s.id }
  description = "Map of subnet name to ID."
}

output "nsg_id" {
  value       = azurerm_network_security_group.this.id
  description = "NSG ID."
}
