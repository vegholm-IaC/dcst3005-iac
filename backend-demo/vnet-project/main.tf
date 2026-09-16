terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-vegholm"  # << endre
    storage_account_name = "sttfstatevegholm01"  # << endre
    container_name       = "tfstate"
    key                  = "rg-vnet.tfstate"
               # navnet på state-fila
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.4"
    }
  }
}

resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.address_space
}