output "public_ip_addresses" {
  description = "Map of public IP name to its allocated IP address."
  value       = { for name, pip in azurerm_public_ip.this : name => pip.ip_address }
}

output "public_ip_fqdns" {
  description = "Map of public IP name to its FQDN (only when domain_name_label is set)."
  value       = { for name, pip in azurerm_public_ip.this : name => pip.fqdn }
}

output "public_ip_ids" {
  description = "Map of public IP name to its id."
  value       = { for name, pip in azurerm_public_ip.this : name => pip.id }
}

output "public_ip_ids_zipmap" {
  description = "Map of public IP name to a { name, id } object, for handing the whole object downstream."
  value       = { for name, pip in azurerm_public_ip.this : name => { name = pip.name, id = pip.id } }
}

output "public_ip_prefix_cidrs" {
  description = "Map of public IP prefix name to its allocated CIDR (ip_prefix)."
  value       = { for name, p in azurerm_public_ip_prefix.this : name => p.ip_prefix }
}

output "public_ip_prefix_ids" {
  description = "Map of public IP prefix name to its id."
  value       = { for name, p in azurerm_public_ip_prefix.this : name => p.id }
}

output "public_ip_prefix_ids_zipmap" {
  description = "Map of public IP prefix name to a { name, id } object."
  value       = { for name, p in azurerm_public_ip_prefix.this : name => { name = p.name, id = p.id } }
}

output "public_ip_prefixes" {
  description = "The full azurerm_public_ip_prefix resources, keyed by name."
  value       = azurerm_public_ip_prefix.this
}

output "public_ips" {
  description = "The full azurerm_public_ip resources, keyed by name."
  value       = azurerm_public_ip.this
}

output "resource_group_name" {
  description = "Resource group name parsed from resource_group_id."
  value       = local.resource_group_name
}

output "subscription_id" {
  description = "Subscription id parsed from resource_group_id."
  value       = local.rg.subscription_id
}

output "tags" {
  description = "The tags applied to the public IPs and prefixes."
  value       = var.tags
}
