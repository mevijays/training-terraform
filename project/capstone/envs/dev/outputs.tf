output "resource_group" { value = azurerm_resource_group.this.name }
output "vnet_id"        { value = module.network.vnet_id }
output "vm_private_ip"  { value = module.vm.private_ip }
output "keyvault_uri"   { value = module.keyvault.uri }
output "cloudfront_url" { value = module.static_site.cloudfront_url }
output "log_workspace"  { value = module.observability.workspace_name }
