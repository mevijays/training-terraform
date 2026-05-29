terraform {
  required_version = ">= 1.12.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = "law-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

# Diagnostic settings for the VNet (or any other resource passed in)
resource "azurerm_monitor_diagnostic_setting" "vnet" {
  count                      = var.vnet_id == null ? 0 : 1
  name                       = "diag-vnet"
  target_resource_id         = var.vnet_id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  enabled_metric {
    category = "AllMetrics"
  }
}
