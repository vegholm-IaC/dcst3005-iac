variable "location" {
  type = string
  default = "northeurope"
}

variable "rg_name" {
  type = string
  default = "rg-demo-network-vegholm"
}

variable "vnet_name" {
  type = string
  default = "vnet-demo-vegholm"
}

variable "address_space" {
  type = list(string)
  default = ["10.10.0.0/16"]
}