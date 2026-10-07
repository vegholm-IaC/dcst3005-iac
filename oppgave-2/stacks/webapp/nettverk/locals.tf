locals {
  common_tags = {
    environment = var.environment
    owner       = var.owner
    managedby   = var.managedby
    kurs        = var.kurs
  }
}