terraform {
  required_version = ">= 1.12.0"
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = "~> 4.0" }
  }
}

resource "azurerm_network_interface" "this" {
  name                = "nic-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  name                            = "vm-${var.name}"
  location                        = var.location
  resource_group_name             = var.resource_group_name
  size                            = var.size
  admin_username                  = var.admin_username
  network_interface_ids           = [azurerm_network_interface.this.id]
  disable_password_authentication = true
  tags                            = var.tags

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  custom_data = base64encode(<<-EOT
    #!/bin/bash
    apt-get update -y
    apt-get install -y python3 nginx
    echo "Hello from NovaPay ${var.name}" > /var/www/html/index.html
    systemctl enable --now nginx
  EOT
  )

  lifecycle {
    create_before_destroy = false
    ignore_changes        = [custom_data]
  }
}
