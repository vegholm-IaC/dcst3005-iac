variable "base_name" {
  type        = string
  description = "Navneprefiks for ressursene i stacken."
}

variable "location" {
  type        = string
  description = "Azure-regionen der stackens ressurser opprettes."
}

variable "vm_size" {
  type        = string
  description = "Azure VM-størrelsen som brukes av compute-modulen."
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

variable "rsg_name" {
  type        = string
  description = "Navnet på ressursgruppen som inneholder stackens ressurser."
}

variable "address_space" {
  type        = string
  description = "Adresseprefikset for det virtuelle nettverket."
}
variable "subnet_ids" {
  type        = map(string)
  description = "Subnett-ID-er, indeksert etter subnettnavn."
}

variable "admin_ssh_public_key" {
  type        = string
  description = "Offentlig SSH-nøkkel som brukes til innlogging på den virtuelle maskinen."
}