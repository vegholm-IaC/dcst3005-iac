variable "base_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vm_size" {
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
  type = string
}

variable "subnets" {
  type        = map(string)
  description = "Subnett som skal opprettes: navn => adresseprefiks"
}

