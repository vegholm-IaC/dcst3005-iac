
variable "location" {
  type        = string
  description = "Deployment Location"
  default     = "West Europe"
}

variable "rgname" {
  type        = string
  description = "Resource Group Name"
  default     = "rg-demo-terraform-vegholm"
}

variable "saname" {
  type        = string
  description = "Storage Account Name - must be globally unique"
  default     = "sa-demo-terraform-vegholm"
}

variable "company" {
  type        = string
  description = "Company name"
}

variable "project" {
  type        = string
  description = "Project name"
}

variable "billing_code" {
  type        = string
  description = "Billing code"

}