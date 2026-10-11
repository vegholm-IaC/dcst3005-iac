terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

resource "azurerm_network_security_group" "nsg" {
  #checkov:skip=CKV_AZURE_10
  name                = lower("nsg-${var.base_name}")
  location            = var.location
  resource_group_name = lower(var.rsg_name)
  tags                = local.common_tags

  security_rule {
    name                       = "ssh-feilsoking"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = lower("vnet-${var.base_name}")
  location            = var.location
  resource_group_name = lower(var.rsg_name)
  address_space       = [var.address_space]
  tags                = local.common_tags
}

resource "azurerm_subnet" "subnet" {
  for_each = var.subnets

  name                 = format("snet-%s-%s", each.key, var.base_name)
  resource_group_name  = lower(var.rsg_name)
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [cidrsubnet(var.address_space, 8, each.value)]
}

resource "azurerm_subnet_network_security_group_association" "snet_nsg" {
  for_each                  = azurerm_subnet.subnet
  subnet_id                 = each.value.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
