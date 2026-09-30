terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.4"
    }
  }
  backend "azurerm" {
  }
}

provider "azurerm" {
  features {}

  resource_providers_to_register = ["Microsoft.Storage"]
}

resource "azurerm_resource_group" "demo" {
  name     = "rg-workflow-vegholm"
  location = "westeurope"
}