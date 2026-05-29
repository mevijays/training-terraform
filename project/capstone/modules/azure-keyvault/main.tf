terraform {
  required_version = ">= 1.12.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
    random  = { source = "hashicorp/random",  version = "~> 3.6" }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                       = "kv-${var.name}-${substr(md5(var.resource_group_name), 0, 6)}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = false
  soft_delete_retention_days = 7
  enable_rbac_authorization  = true
  tags                       = var.tags

  lifecycle {
    precondition {
      condition     = var.env != "prod" || var.location == "westeurope"
      error_message = "Prod Key Vaults must live in westeurope."
    }
  }
}

# The caller (you) gets Secrets Officer so apply can write the secret
resource "azurerm_role_assignment" "kv_secrets_officer" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "random_password" "db" {
  length  = 24
  special = true
}

resource "azurerm_key_vault_secret" "db_password" {
  name         = "db-password"
  value        = random_password.db.result
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [azurerm_role_assignment.kv_secrets_officer]
}
