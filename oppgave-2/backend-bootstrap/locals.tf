locals {
  tags = {
    keep      = "true"
    owner     = var.owner
    managedby = var.managedby
    purpose   = var.purpose
  }
}