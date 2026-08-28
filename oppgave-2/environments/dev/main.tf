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

resource "azurerm_resource_group" "rg" {
  name     = lower("rg-${var.base_name}")
  location = var.location
  tags     = local.common_tags
}

module "network" {
  source      = "../../modules/network"
  rsg_name    = azurerm_resource_group.rg.name
  location    = var.location
  base_name   = lower(var.base_name)
  environment = var.environment
  owner       = var.owner
  managedby   = var.managedby
}

module "compute" {
  source      = "../../modules/compute"
  rsg_name    = azurerm_resource_group.rg.name
  base_name   = lower(var.base_name)
  location    = var.location
  vm_size     = lower(var.vm_size)
  subnet_id   = module.network.subnet_id
  environment = var.environment
  owner       = var.owner
  managedby   = var.managedby
}