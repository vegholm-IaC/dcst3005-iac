terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

resource "azurerm_network_security_group" "nsg" {
  name                = lower("nsg-${var.base_name}")
  location            = var.location
  resource_group_name = lower(var.rsg_name)
  tags                = local.common_tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = lower("vnet-${var.base_name}")
  location            = var.location
  resource_group_name = lower(var.rsg_name)
  address_space       = ["10.0.0.0/16"]
  tags                = local.common_tags
}

resource "azurerm_subnet" "subnet" {
  name                 = lower("subnet-${var.base_name}")
  resource_group_name  = lower(var.rsg_name)
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.10.0/24"]
}

resource "azurerm_subnet_network_security_group_association" "snet_nsg" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}