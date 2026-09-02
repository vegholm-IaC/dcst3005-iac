output "subnet_ids" {
  value       = { for k, s in azurerm_subnet.subnet : k => s.id }
  description = "ID-ene til alle subnettene, i samme rekkefølge som subnet_names"
}