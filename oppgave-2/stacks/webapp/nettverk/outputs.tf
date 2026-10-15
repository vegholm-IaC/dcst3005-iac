output "subnet_ids" {
  description = "Subnett-ID-er fra nettverksmodulen, indeksert etter subnettnavn."
  value       = module.nettverk.subnet_ids
}