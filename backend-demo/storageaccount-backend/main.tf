terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.4"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "a3adf20e-4966-4afb-b717-4de1baae6db1"
  use_cli         = true # Bruker pålogging via `az login`

  # Fra og med azurerm 5.0 registreres ingen resource providers automatisk
  resource_providers_to_register = ["Microsoft.Storage"]
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-tfstate-vegholm"
  location = "westeurope"
}

resource "azurerm_storage_account" "sa" {
  name                     = "sttfstatevegholm01" # må være globalt unikt
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "sc" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.sa.id
  container_access_type = "private"
}

# Hent innlogget bruker fra Entra ID
data "azurerm_client_config" "current" {}

# Tilgang slik at innlogget bruker kan liste innholdet i containeren
resource "azurerm_role_assignment" "blob_reader" {
  scope                = azurerm_storage_account.sa.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = data.azurerm_client_config.current.object_id

  # Sørg for at SA og container er ferdig opprettet før RBAC forsøkes
  depends_on = [
    azurerm_storage_account.sa,
    azurerm_storage_container.sc
  ]
}

