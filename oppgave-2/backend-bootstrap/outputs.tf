output "backend_hcl_template" {
  description = "HCL-konfigurasjon for å koble Terraform til backend-containeren."
  value       = <<EOT
  resource_group_name = "${azurerm_resource_group.rg.name}"
  storage_account_name = "${azurerm_storage_account.sa.name}"
  container_name = "${azurerm_storage_container.sc.name}"
  use_azuread_auth = true
  EOT
}

output "keyvault_name" {
  description = "Navnet på Key Vault-et som brukes til å lagre secrets."
  value       = azurerm_key_vault.kv.name
}