variable "base_name" {
  type        = string
  description = "Navneprefiks for ressursene i dev-miljøet."
}

variable "location" {
  type        = string
  description = "Azure-regionen der dev-ressursene opprettes."
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

variable "address_space" {
  type        = string
  description = "Adresseprefikset for det virtuelle nettverket."
}

variable "subnets" {
  type        = map(string)
  description = "Subnett som skal opprettes: navn => adresseprefiks"
}

variable "subscription_id" {
  type        = string
  description = "ID-en til Azure-abonnementet for dev-miljøet."
}

variable "admin_ssh_public_key" {
  type        = string
  description = "Offentlig SSH-nøkkel som brukes til innlogging på dev-VM-en."
}