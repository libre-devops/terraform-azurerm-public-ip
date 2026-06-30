locals {
  location = lookup(var.regions, var.loc, "uksouth")
  rg_name  = "rg-${var.short}-${var.loc}-${terraform.workspace}-001"
  prefix   = "ippre-${var.short}-${var.loc}-${terraform.workspace}-001"
}

module "tags" {
  source  = "libre-devops/tags/azurerm"
  version = "~> 4.0"

  cost_centre     = "1888/67"
  owner           = "platform@example.com"
  deployed_branch = var.deployed_branch
  deployed_repo   = var.deployed_repo
}

module "rg" {
  source  = "libre-devops/rg/azurerm"
  version = "~> 4.0"

  resource_groups = [{ name = local.rg_name, location = local.location, tags = module.tags.tags }]
}

# Complete call: a zone-redundant prefix, a public IP allocated from it, and a standalone zonal public
# IP with a custom idle timeout.
module "public_ip" {
  source = "../../"

  resource_group_id = module.rg.ids[local.rg_name]
  location          = local.location
  tags              = module.tags.tags

  public_ip_prefixes = {
    (local.prefix) = {
      prefix_length = 30
      zones         = ["1", "2", "3"]
    }
  }

  public_ips = {
    "pip-${var.short}-${var.loc}-${terraform.workspace}-001" = {
      prefix_key = local.prefix
    }
    "pip-${var.short}-${var.loc}-${terraform.workspace}-002" = {
      zones                   = ["1", "2", "3"]
      idle_timeout_in_minutes = 10
    }
  }
}
