output "id"   { value = azurerm_key_vault.this.id }
output "name" { value = azurerm_key_vault.this.name }
output "uri"  { value = azurerm_key_vault.this.vault_uri }

output "db_password_secret_id" {
  value       = azurerm_key_vault_secret.db_password.id
  description = "ID of the generated DB password secret."
}
