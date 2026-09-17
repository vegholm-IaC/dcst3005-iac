variable "purpose" {
  type = string
}

variable "owner" {
  type = string
}

variable "managedby" {
  type = string
}

variable "base_name" {
  type = string
}

variable "subscription_id" {
  type = string
}

variable "location" {
  type = string
}

variable "pipeline_principal_id" {
  description = "Object-ID til service principal-en workflowen logger inn som"
  type        = string
}