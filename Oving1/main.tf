terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "a3adf20e-4966-4afb-b717-4de1baae6db1"
}

resource "azurerm_resource_group" "rg-o1" {
  name     = "rg-${var.name}"
  location = var.Location
  tags     = local.tags
}

resource "azurerm_network_security_group" "nsg-o1" {
  name                = "nsg-${var.name}"
  location            = var.Location
  resource_group_name = azurerm_resource_group.rg-o1.name
  tags                = local.tags
}

resource "azurerm_virtual_network" "vn-o1" {
  name                = "vn-${var.name}"
  location            = var.Location
  resource_group_name = azurerm_resource_group.rg-o1.name
  address_space       = ["10.0.0.0/16"]
  dns_servers         = ["10.0.0.4", "10.0.0.5"]

  subnet {
    name             = "subnet1"
    address_prefixes = ["10.0.1.0/24"]
  }

  subnet {
    name             = "subnet2"
    address_prefixes = ["10.0.2.0/24"]
    security_group   = azurerm_network_security_group.nsg-o1.id
  }

  tags = local.tags
}