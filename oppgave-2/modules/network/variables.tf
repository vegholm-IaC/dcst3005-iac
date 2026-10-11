variable "location" {
  type        = string
  description = "Azure-regionen der nettverksressursene opprettes."
}
variable "base_name" {
  type        = string
  description = "Navneprefiks for nettverksressursene."
}

variable "rsg_name" {
  type        = string
  description = "Navnet på ressursgruppen for nettverksressursene."
}

variable "environment" {
  type        = string
  description = "Miljønavnet som legges på ressursene som tag."
}

variable "owner" {
  type        = string
  description = "Eier av ressursene, brukt som tag."
}

variable "managedby" {
  type        = string
  description = "Verktøyet eller teamet som administrerer ressursene, brukt som tag."
}

variable "address_space" {
  type        = string
  description = "Adresserommet vnet-et disponerer, som CIDR – for eksempel 10.10.0.0/16"
}

variable "subnets" {
  type        = map(string)
  description = "Subnett som skal opprettes: navn => adresseprefiks"
}