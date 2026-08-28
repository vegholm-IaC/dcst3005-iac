variable "rg_name" {
  type    = string
  default = "rg-tf-demo-vegholm"
}

variable "location" {
  type    = string
  default = "West Europe"
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

variable "sa_name" {
  type    = string
  default = "stterraformdemovegholm"
}

variable "mssql_name" {
  type    = string
  default = "sql-tf-demo-001-vegholm"
}

variable "mssql_db_name" {
  type    = string
  default = "sqldb-tf-demo-vegholm"
}

variable "vmss_name" {
  type    = string
  default = "vmss-tf"
}