# Public IP prefixes and public IPs, keyed maps for stable for_each. The resource group is passed by
# id and parsed (per the pass-ids standard). A public IP can allocate from a prefix created in this
# same module via prefix_key, or from an external prefix via public_ip_prefix_id.
locals {
  rg                  = provider::azurerm::parse_resource_id(var.resource_group_id)
  resource_group_name = local.rg.resource_group_name
}

resource "azurerm_public_ip_prefix" "this" {
  for_each = var.public_ip_prefixes

  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = merge(var.tags, each.value.tags)

  name          = each.key
  prefix_length = each.value.prefix_length
  sku           = each.value.sku
  sku_tier      = each.value.sku_tier
  ip_version    = each.value.ip_version
  zones         = each.value.zones
}

resource "azurerm_public_ip" "this" {
  for_each = var.public_ips

  resource_group_name = local.resource_group_name
  location            = var.location
  tags                = merge(var.tags, each.value.tags)

  name                    = each.key
  allocation_method       = each.value.allocation_method
  sku                     = each.value.sku
  sku_tier                = each.value.sku_tier
  ip_version              = each.value.ip_version
  zones                   = each.value.zones
  idle_timeout_in_minutes = each.value.idle_timeout_in_minutes
  domain_name_label       = each.value.domain_name_label
  domain_name_label_scope = each.value.domain_name_label_scope
  reverse_fqdn            = each.value.reverse_fqdn
  public_ip_prefix_id     = each.value.prefix_key != null ? azurerm_public_ip_prefix.this[each.value.prefix_key].id : each.value.public_ip_prefix_id
  ddos_protection_mode    = each.value.ddos_protection_mode
  ddos_protection_plan_id = each.value.ddos_protection_plan_id
  edge_zone               = each.value.edge_zone
  ip_tags                 = each.value.ip_tags
}
