terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.44.1"
    }
  }
  cloud {
    organization = "mevijays"
    workspaces {
      name = "training-terraform"
    }
  }
}
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}
/*
variable "VMCOUNT" {
  default  = 1
  type     = number
}

variable "rg_name" {
  type = string
  default = "krlab"
}
# Create a resource group
resource "azurerm_resource_group" "krlabrg" {
  name     = var.rg_name
  location = "eastus"
}

# Create a virtual network within the resource group
resource "azurerm_virtual_network" "labvnet" {
  name                = "labvnet"
  resource_group_name = azurerm_resource_group.krlabrg.name
  location            = azurerm_resource_group.krlabrg.location
  address_space       = ["10.0.0.0/16"]
  depends_on          = [
    azurerm_resource_group.krlabrg,
  ]
}

# Create a vm subnet 
resource "azurerm_subnet" "vmsubnet" {
  name                 = "vmsubnet"
  resource_group_name  = azurerm_resource_group.krlabrg.name
  virtual_network_name = azurerm_virtual_network.labvnet.name
  address_prefixes     = ["10.0.1.0/24"]
  depends_on          = [
    azurerm_resource_group.krlabrg,
    azurerm_virtual_network.labvnet
  ]
}

## creating NSG with all inbound allow
resource "azurerm_network_security_group" "vmnsg" {
  name                = "vmnsg"
  location            = azurerm_resource_group.krlabrg.location
  resource_group_name = azurerm_resource_group.krlabrg.name

  security_rule {
    name                       = "allallow"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}
## associate NSG with vm subnet
resource "azurerm_subnet_network_security_group_association" "vmnetnsg" {
  subnet_id                 = azurerm_subnet.vmsubnet.id
  network_security_group_id = azurerm_network_security_group.vmnsg.id
}
### creating public ips
resource "azurerm_public_ip" "eip" {
  count               = var.VMCOUNT
  name                = "webvmip-${count.index}"
  resource_group_name = azurerm_resource_group.krlabrg.name
  location            = azurerm_resource_group.krlabrg.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}


# Create a dev subnet 
resource "azurerm_subnet" "devsubnet" {
  name                 = "devsubnet"
  resource_group_name  = azurerm_resource_group.krlabrg.name
  virtual_network_name = azurerm_virtual_network.labvnet.name
  address_prefixes     = ["10.0.2.0/24"]
  depends_on          = [
    azurerm_resource_group.krlabrg,
    azurerm_virtual_network.labvnet
  ]
}
# Create a prod vm subnet 
resource "azurerm_subnet" "prodsubnet" {
  name                 = "prodsubnet"
  resource_group_name  = azurerm_resource_group.krlabrg.name
  virtual_network_name = azurerm_virtual_network.labvnet.name
  address_prefixes     = ["10.0.3.0/24"]
  depends_on          = [
    azurerm_resource_group.krlabrg,
    azurerm_virtual_network.labvnet
  ]
}

resource "azurerm_network_interface" "webvm" {
  count               = var.VMCOUNT
  name                = "webvm${count.index}-nic"
  location            = azurerm_resource_group.krlabrg.location
  resource_group_name = azurerm_resource_group.krlabrg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vmsubnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = element(azurerm_public_ip.eip.*.id, count.index) 
  }
  depends_on          = [
        azurerm_subnet.vmsubnet,
        azurerm_public_ip.eip
 ]
}

resource "azurerm_linux_virtual_machine" "webvm" {
  count               = var.VMCOUNT
  name                = "webvm-${count.index}"
  resource_group_name = azurerm_resource_group.krlabrg.name
  location            = azurerm_resource_group.krlabrg.location
  size                = "Standard_B1s"
  admin_username      = "vijay"
  network_interface_ids =  [element(azurerm_network_interface.webvm.*.id, count.index)]

  admin_ssh_key {
    username   = "vijay"
    public_key = file("id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  custom_data    = base64encode(local.custom_data)
  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_9"
    version   = "latest"
  }
  depends_on          = [
        azurerm_subnet.vmsubnet,
        azurerm_network_interface.webvm
 ]
}
locals {
  custom_data = file("azure-user-data.sh")
  }

resource "azurerm_storage_account" "main" {
  name                     = "krlabmonstrbatch"
  resource_group_name      = azurerm_resource_group.krlabrg.name
  location                 = azurerm_resource_group.krlabrg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  tags = {
    environment = "staging"
  }
}

variable "is_create_law" {
  type = bool
  default = false
}
resource "azurerm_log_analytics_workspace" "main" {
count = var.is_create_law ? 1 : 0
  name                = "linux-vmalaw"
  location            = azurerm_resource_group.krlabrg.location
  resource_group_name = azurerm_resource_group.krlabrg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
*/
