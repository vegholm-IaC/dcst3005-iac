variable "base_name" {
  type        = string
  description = "Navneprefiks for ressursene i webapp-nettverksstacken."
}

variable "location" {
  type        = string
  description = "Azure-regionen der nettverksressursene opprettes."
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

variable "kurs" {
  type        = string
  description = "Kurskoden som brukes til å identifisere ressursene."
}

variable "address_space" {
  type        = string
  description = "Adresseprefikset for det virtuelle nettverket."
}

variable "subnets" {
  type        = map(string)
  description = "Subnett som skal opprettes: navn => adresseprefiks"
}
