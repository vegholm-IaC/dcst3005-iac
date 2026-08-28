variable "subnet_id" {
  type        = string
  default     = ""
  description = "ID-en til subnet-et VM-ene skal kobles på"
}

variable "rg_name" {
  type    = string
  default = "rg-tf-demo-vegholm"
}

variable "location" {
  type    = string
  default = "West Europe"
}

variable "vmss_name" {
  type    = string
  default = "vmss-tf"
}