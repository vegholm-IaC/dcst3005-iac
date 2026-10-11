terraform {
  required_version = ">= 1.0.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.9"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id     = var.subscription_id
  storage_use_azuread = true
}

data "azurerm_client_config" "current" {}

resource "random_string" "suffix" {
  length  = 6
  lower   = true
  numeric = true
  upper   = false
  special = false
}

resource "azurerm_resource_group" "rg" {
  name     = format("rg-tfstate-%s", var.base_name)
  location = var.location
  tags     = local.tags
}

# tflint-ignore: azurerm_resources_missing_prevent_destroy # Backend-lagringskontoen må kunne slettes ved opprydding av studentoppsettet.
resource "azurerm_storage_account" "sa" {
  #checkov:skip=CKV_AZURE_59:GitHub Actions-runneren må kunne nå state over internett i studentoppsettet.
  #checkov:skip=CKV_AZURE_33:Storage-kontoen brukes ikke til køer.
  #checkov:skip=CKV_AZURE_206:LRS er valgt for å unngå kostnaden ved geo-replikering; state har versjonering og soft delete.
  #checkov:skip=CKV2_AZURE_33:Privat endepunkt krever et privat nettverk som GitHub Actions-runneren ikke er koblet til.
  #checkov:skip=CKV2_AZURE_1:Microsoft-administrerte nøkler er tilstrekkelig for dette studentoppsettet.
  name                = lower(format("sttf%s%s", var.base_name, random_string.suffix.result))
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  account_tier             = "Standard"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"

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

# tflint-ignore: azurerm_resources_missing_prevent_destroy # Backend-containeren må kunne slettes ved opprydding av studentoppsettet.
resource "azurerm_storage_container" "sc" {
  #checkov:skip=CKV2_AZURE_21:Leselogging for state-containeren gir ekstra lagrings- og oppsettskostnad utenfor studentoppsettet.
  name                  = format("tfstate-%s", var.base_name)
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
# tflint-ignore: azurerm_resources_missing_prevent_destroy # Key Vault-et har soft delete og kan gjenopprettes
resource "azurerm_key_vault" "kv" {
  #checkov:skip=CKV_AZURE_189:GitHub Actions-runneren må kunne hente parameterfila over internett i studentoppsettet.
  #checkov:skip=CKV_AZURE_109:Brannmurregler ville sperret GitHub Actions-runneren ute fra parameterfila.
  #checkov:skip=CKV2_AZURE_32:Privat endepunkt krever et privat nettverk som GitHub Actions-runneren ikke er koblet til.
  #checkov:skip=CKV_AZURE_110:Purge protection hindrer opprydding i et studentoppsett
  #checkov:skip=CKV_AZURE_42:Krever purge protection, se CKV_AZURE_110
  name                = substr(lower("kv-tf-${var.base_name}${random_string.suffix.result}"), 0, 24)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  rbac_authorization_enabled = true
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

  tags = local.tags
}

# Du skal kunne SKRIVE secrets — det er du som laster opp parameterverdiene.
resource "azurerm_role_assignment" "kv_officer_meg" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
  principal_type       = "User"
}

resource "azurerm_role_assignment" "kv_user_pipeline" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.pipeline_principal_id
  principal_type       = "ServicePrincipal"
}
resource "azurerm_role_assignment" "pipeline_blob_contributor" {
  scope                = azurerm_storage_account.sa.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.pipeline_principal_id
  principal_type       = "ServicePrincipal"

  depends_on = [
    azurerm_storage_account.sa,
    azurerm_storage_container.sc
  ]
}