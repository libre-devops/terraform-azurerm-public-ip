# check blocks run after every plan and apply and emit a warning (without blocking) when an
# invariant is violated. They are the place to enforce module-wide consistency.

check "all_public_ips_created" {
  assert {
    condition     = length(azurerm_public_ip.this) == length(var.public_ips) && length(azurerm_public_ip_prefix.this) == length(var.public_ip_prefixes)
    error_message = "Fewer public IPs or prefixes were created than requested; check for duplicate names."
  }
}

# A public IP's prefix_key must name a prefix created in this module (otherwise the allocation
# silently references a missing prefix).
check "prefix_keys_reference_known_prefixes" {
  assert {
    condition = alltrue([
      for p in values(var.public_ips) : p.prefix_key == null ? true : contains(keys(var.public_ip_prefixes), p.prefix_key)
    ])
    error_message = "A public IP prefix_key does not match any key in public_ip_prefixes."
  }
}
