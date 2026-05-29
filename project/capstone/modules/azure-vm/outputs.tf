output "id"          { value = azurerm_linux_virtual_machine.this.id }
output "name"        { value = azurerm_linux_virtual_machine.this.name }
output "private_ip"  { value = azurerm_network_interface.this.private_ip_address }
