variable "base_name" {
  type        = string
  description = "Felles navn som identifiserer alle ressursene i denne konfigurasjonen"
}

variable "rg_name" {
  type        = string
  description = "Navnet på resource group-en storage account-en skal ligge i"
}

variable "location" {
  type        = string
  description = "Azure-regionen ressursene opprettes i"
}