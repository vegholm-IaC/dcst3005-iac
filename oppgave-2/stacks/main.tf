terraform {
  required_version = ">= 1.0.0"
}

module "network" {
  source        = "../modules/network"
  rsg_name      = var.rsg_name
  location      = var.location
  base_name     = lower(var.base_name)
  environment   = var.environment
  owner         = var.owner
  managedby     = var.managedby
  address_space = var.address_space
  subnets       = var.subnet_ids
}

module "compute" {
  source               = "../modules/compute"
  rsg_name             = var.rsg_name
  base_name            = lower(var.base_name)
  location             = var.location
  vm_size              = var.vm_size
  subnet_id            = module.network.subnet_ids["web"]
  environment          = var.environment
  owner                = var.owner
  managedby            = var.managedby
  admin_ssh_public_key = var.admin_ssh_public_key
}