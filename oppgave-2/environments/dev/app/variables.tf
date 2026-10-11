variable "base_name" {
  type        = string
  description = "Navneprefiks for ressursene i dev-applikasjonen."
}

variable "location" {
  type        = string
  description = "Azure-regionen der applikasjonsressursene opprettes."
}

variable "vm_size" {
  type        = string
  description = "Azure VM-størrelsen for applikasjonsserveren."
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

variable "subscription_id" {
  type        = string
  description = "ID-en til Azure-abonnementet for dev-miljøet."
}

variable "vm_subnet_key" {
  type        = string
  description = "Nøkkelen til subnettet i nettverkets remote state."
}

variable "rg_name_backend" {
  type        = string
  description = "Navnet på ressursgruppen som inneholder Terraform-backenden."
}

variable "sa_name_backend" {
  type        = string
  description = "Navnet på lagringskontoen som inneholder Terraform-backenden."
}

variable "container_name_backend" {
  type        = string
  description = "Navnet på blob-containeren som inneholder Terraform-state."
}

variable "nettverk_state_key" {
  type        = string
  description = "Blob-nøkkelen til nettverkets Terraform-state."
}

variable "admin_ssh_public_key" {
  type        = string
  description = "Offentlig SSH-nøkkel som brukes til innlogging på dev-VM-en."
}
