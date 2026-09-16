locals {
  common_tags = {
    environment = var.environment
    owner       = var.owner
    managedby   = var.managedby
  }
  subnet_id = data.terraform_remote_state.network.outputs.subnet_ids[var.vm_subnet_key]
}