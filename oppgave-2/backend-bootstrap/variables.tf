variable "purpose" {
  type        = string
  description = "Formålet med backend-ressursgruppen."
}

variable "owner" {
  type        = string
  description = "Eier av infrastrukturen."
}

variable "managedby" {
  type        = string
  description = "Verktøyet eller teamet som administrerer infrastrukturen."
}

variable "base_name" {
  type        = string
  description = "Navneprefiks som brukes på backend-ressursene."
}

variable "subscription_id" {
  type        = string
  description = "ID-en til Azure-abonnementet der backend opprettes."
}

variable "location" {
  type        = string
  description = "Azure-regionen der backend-ressursene opprettes."
}

variable "pipeline_principal_id" {
  description = "Object-ID til service principal-en workflowen logger inn som"
  type        = string
}