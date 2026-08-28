terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

resource "azurerm_resource_group" "rg" {
  name     = format("rg-%s", lower(var.base_name))
  location = var.location
}