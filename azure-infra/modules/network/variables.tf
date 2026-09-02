variable "rg_name" {
  type = string
}

variable "location" {
  type = string
}

variable "vnet_name" {
  type    = string
  default = "vnet-tf-demo-01-vegholm"
}

variable "nsg_name" {
  type    = string
  default = "nsg-tf-demo-vegholm"
}

variable "subnet_name" {
  type    = string
  default = "snet-tf-demo-001-vegholm"
}

variable "subnets" {
  type        = map(string)
  description = "Subnett som skal opprettes: navn => adresseprefiks"

  default = {
    web  = "10.0.1.0/24"
    app  = "10.0.2.0/24"
    data = "10.0.3.0/24"
  }
}