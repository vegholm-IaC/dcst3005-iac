terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
  backend "azurerm" {}
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "rg" {
  name     = lower("rg-${var.base_name}")
  location = var.location
  tags     = local.common_tags
}

module "stacks" {
  source    = "../../stacks"
  rsg_name  = azurerm_resource_group.rg.name
  base_name = lower(var.base_name)
  location  = var.location
  # tflint-ignore: azurerm_virtual_machine_invalid_vm_size # Gyldig nyere SKU som mangler i allowlisten til ruleset 0.32.0.
  vm_size              = var.vm_size
  environment          = var.environment
  owner                = var.owner
  managedby            = var.managedby
  subnet_ids           = var.subnets
  address_space        = var.address_space
  admin_ssh_public_key = var.admin_ssh_public_key
}