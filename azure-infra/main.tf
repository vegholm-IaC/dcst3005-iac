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
  name     = var.rg_name
  location = var.location
}

module "network" {
  source      = "./modules/network"
  rg_name     = azurerm_resource_group.rg.name
  location    = var.location
  vnet_name   = var.vnet_name
  nsg_name    = var.nsg_name
  subnet_name = var.subnet_name
}

module "database" {
  source        = "./modules/database"
  rg_name       = azurerm_resource_group.rg.name
  location      = var.location
  sa_name       = var.sa_name
  mssql_name    = var.mssql_name
  mssql_db_name = var.mssql_db_name
}

module "vmss" {
  source    = "./modules/vmss"
  rg_name   = azurerm_resource_group.rg.name
  location  = var.location
  vmss_name = var.vmss_name
  subnet_id = module.network.subnet_id
}
