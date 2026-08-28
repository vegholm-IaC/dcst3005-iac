variable "rg_name" {
  type = string
}

variable "location" {
  type = string
}

variable "sa_name" {
  type    = string
  default = "stterraformdemovegholm"
}

variable "mssql_db_name" {
  type    = string
  default = "sqldb-tf-demo-vegholm"
}


variable "mssql_name" {
  type    = string
  default = "sql-tf-demo-001-vegholm"
}