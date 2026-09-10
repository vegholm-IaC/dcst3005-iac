variable "location" {
  type = string
}
variable "base_name" {
  type = string
}

variable "rsg_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "owner" {
  type = string
}

variable "managedby" {
  type = string
}

variable "address_space" {
  type        = string
  description = "Adresserommet vnet-et disponerer, som CIDR – for eksempel 10.10.0.0/16"
}

variable "subnets" {
  type        = map(string)
  description = "Subnett som skal opprettes: navn => adresseprefiks"
}