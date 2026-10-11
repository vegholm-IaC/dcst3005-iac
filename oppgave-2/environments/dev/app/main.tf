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
  name     = lower("rg-app-${var.base_name}")
  location = var.location
  tags     = local.common_tags
}

data "terraform_remote_state" "network" {
  backend = "azurerm"
  config = {
    resource_group_name  = var.rg_name_backend
    storage_account_name = var.sa_name_backend
    container_name       = var.container_name_backend
    key                  = var.nettverk_state_key
    use_azuread_auth     = true
  }
}

module "compute" {
  source    = "../../../modules/compute"
  rsg_name  = azurerm_resource_group.rg.name
  base_name = lower(var.base_name)
  location  = var.location
  # tflint-ignore: azurerm_virtual_machine_invalid_vm_size # Gyldig nyere SKU som mangler i allowlisten til ruleset 0.32.0.
  vm_size              = var.vm_size
  subnet_id            = local.subnet_id
  environment          = var.environment
  owner                = var.owner
  managedby            = var.managedby
  admin_ssh_public_key = var.admin_ssh_public_key
}