variable "location" {
  type        = string
  description = "Azure-regionen der compute-ressursene opprettes."
}
variable "base_name" {
  type        = string
  description = "Navneprefiks for compute-ressursene."
}

variable "rsg_name" {
  type        = string
  description = "Navnet på ressursgruppen for compute-ressursene."
}

variable "vm_size" {
  type        = string
  description = "Azure VM-størrelsen for den virtuelle maskinen."
}

variable "subnet_id" {
  type        = string
  description = "ID-en til subnettet som nettverksgrensesnittet kobles til."
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

variable "admin_ssh_public_key" {
  type        = string
  description = "Offentlig SSH-nøkkel som brukes til innlogging på den virtuelle maskinen."
}