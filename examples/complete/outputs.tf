output "public_ip_addresses" {
  description = "Map of public IP name to its allocated address."
  value       = module.public_ip.public_ip_addresses
}

output "public_ip_ids" {
  description = "Map of public IP name to id."
  value       = module.public_ip.public_ip_ids
}

output "public_ip_prefix_cidrs" {
  description = "Map of public IP prefix name to its allocated CIDR."
  value       = module.public_ip.public_ip_prefix_cidrs
}

output "tags" {
  description = "The tags applied to the resources."
  value       = module.tags.tags
}
