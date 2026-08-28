terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

resource "azurerm_storage_account" "sa" {
  name                     = var.sa_name
  resource_group_name      = var.rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_mssql_server" "sql" {
  name                         = var.mssql_name
  resource_group_name          = var.rg_name
  location                     = var.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "Bytt-meg-1234!"
}

resource "azurerm_mssql_database" "db" {
  name           = var.mssql_db_name
  server_id      = azurerm_mssql_server.sql.id
  sku_name       = "Basic"
  max_size_gb    = 2
  read_scale     = false
  zone_redundant = false

  lifecycle {
    prevent_destroy = false
  }
}