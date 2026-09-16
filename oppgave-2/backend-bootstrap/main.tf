provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
  storage_use_azuread = true
}

data "azurerm_client_config" "current" {}

resource "random_string" "suffix" {
  length = 6
  lower = true
  numeric = true
  upper = false
  special = false
}

resource "azurerm_resource_group" "rg" {
  name     = format("rg-tfstate-%s", var.base_name)
  location = var.location
  tags = local.tags
}

resource "azurerm_storage_account" "sa" {
  name                     = lower(format("sttf%s%s",var.base_name,random_string.suffix.result)) 
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  
  account_tier             = "Standard"
  account_kind = "StorageV2"
  account_replication_type = "LRS"
  
  shared_access_key_enabled       = false
  default_to_oauth_authentication = true
  allow_nested_items_to_be_public = false

  blob_properties {
    versioning_enabled = true
    delete_retention_policy {
      days = 7
    }
    container_delete_retention_policy {
      days = 7
    }
  }

}

resource "azurerm_storage_container" "sc" {
  name                  = format("tfstate-%s",var.base_name)
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "private"
}

resource "azurerm_role_assignment" "blob_contrib_self_account_scope" {
  scope                = azurerm_storage_account.sa.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azurerm_client_config.current.object_id
  principal_type       = "User"

  # Sørg for at kontoen er ferdig opprettet før RBAC forsøkes
  depends_on = [
    azurerm_storage_account.sa,
    azurerm_storage_container.sc
  ]
}
