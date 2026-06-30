variable "location" {
  description = "Azure region for the public IPs and prefixes."
  type        = string
}

variable "public_ip_prefixes" {
  description = <<-EOT
    Public IP prefixes to create, keyed by name. A public IP can draw from one of these in the same
    module via its prefix_key. Defaults to a Standard regional IPv4 /28.
  EOT
  type = map(object({
    prefix_length = optional(number, 28)
    sku           = optional(string, "Standard")
    sku_tier      = optional(string, "Regional")
    ip_version    = optional(string, "IPv4")
    zones         = optional(list(string), [])
    tags          = optional(map(string), {})
  }))
  default = {}

  validation {
    condition     = alltrue([for name in keys(var.public_ip_prefixes) : length(name) >= 1 && length(name) <= 80])
    error_message = "Each public IP prefix name must be 1 to 80 characters."
  }

  validation {
    condition     = alltrue([for p in values(var.public_ip_prefixes) : p.prefix_length >= 0 && p.prefix_length <= 31])
    error_message = "public_ip_prefixes[*].prefix_length must be between 0 and 31."
  }

  validation {
    condition     = alltrue([for p in values(var.public_ip_prefixes) : contains(["Standard", "StandardV2"], p.sku)])
    error_message = "public_ip_prefixes[*].sku must be Standard or StandardV2."
  }
}

variable "public_ips" {
  description = <<-EOT
    Public IPs to create, keyed by name. Secure defaults: Standard SKU with Static allocation (Basic is
    retired and Standard requires Static). Set prefix_key to allocate from a public_ip_prefixes entry in
    this module, or public_ip_prefix_id for an external prefix (not both).
  EOT
  type = map(object({
    allocation_method       = optional(string, "Static")
    sku                     = optional(string, "Standard")
    sku_tier                = optional(string, "Regional")
    ip_version              = optional(string, "IPv4")
    zones                   = optional(list(string), [])
    idle_timeout_in_minutes = optional(number, 4)
    domain_name_label       = optional(string)
    domain_name_label_scope = optional(string)
    reverse_fqdn            = optional(string)
    prefix_key              = optional(string)
    public_ip_prefix_id     = optional(string)
    ddos_protection_mode    = optional(string, "VirtualNetworkInherited")
    ddos_protection_plan_id = optional(string)
    edge_zone               = optional(string)
    ip_tags                 = optional(map(string), {})
    tags                    = optional(map(string), {})
  }))
  default = {}

  validation {
    condition     = alltrue([for name in keys(var.public_ips) : length(name) >= 1 && length(name) <= 80])
    error_message = "Each public IP name must be 1 to 80 characters."
  }

  validation {
    condition     = alltrue([for p in values(var.public_ips) : contains(["Basic", "Standard", "StandardV2"], p.sku)])
    error_message = "public_ips[*].sku must be Basic, Standard, or StandardV2 (Basic is retired; prefer Standard)."
  }

  validation {
    condition     = alltrue([for p in values(var.public_ips) : contains(["Static", "Dynamic"], p.allocation_method)])
    error_message = "public_ips[*].allocation_method must be Static or Dynamic."
  }

  validation {
    condition     = alltrue([for p in values(var.public_ips) : p.sku == "Basic" || p.allocation_method == "Static"])
    error_message = "Standard and StandardV2 public IPs require allocation_method = \"Static\"."
  }

  validation {
    condition     = alltrue([for p in values(var.public_ips) : contains(["Disabled", "Enabled", "VirtualNetworkInherited"], p.ddos_protection_mode)])
    error_message = "public_ips[*].ddos_protection_mode must be Disabled, Enabled, or VirtualNetworkInherited."
  }

  validation {
    condition     = alltrue([for p in values(var.public_ips) : !(p.prefix_key != null && p.public_ip_prefix_id != null)])
    error_message = "Set only one of prefix_key or public_ip_prefix_id on a public IP."
  }
}

variable "resource_group_id" {
  description = "Resource id of the resource group to create the public IPs and prefixes in. The name and subscription are parsed from it (pass the rg module's ids output)."
  type        = string

  validation {
    condition     = try(provider::azurerm::parse_resource_id(var.resource_group_id).resource_type, "") == "resourceGroups"
    error_message = "resource_group_id must be a resource group id of the form /subscriptions/<sub>/resourceGroups/<name>."
  }
}

variable "tags" {
  description = "Tags applied to every public IP and prefix (merged with any per-resource tags)."
  type        = map(string)
  default     = {}
}
