# Plan-time tests for the module. The azurerm provider is mocked, so no credentials, no
# features block, and no cloud calls are needed:
#   terraform init -backend=false && terraform test

mock_provider "azurerm" {}

variables {
  resource_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-ldo-uks-tst-001"
  location          = "uksouth"
  public_ips = {
    "pip-ldo-uks-tst-001" = {}
  }
}

run "creates_public_ip_with_secure_defaults" {
  command = plan

  assert {
    condition     = azurerm_public_ip.this["pip-ldo-uks-tst-001"].sku == "Standard" && azurerm_public_ip.this["pip-ldo-uks-tst-001"].allocation_method == "Static"
    error_message = "Public IPs should default to Standard SKU with Static allocation."
  }

  assert {
    condition     = output.resource_group_name == "rg-ldo-uks-tst-001"
    error_message = "resource_group_name should be parsed from resource_group_id."
  }
}

run "creates_prefix_and_allocates_a_public_ip_from_it" {
  command = plan

  variables {
    public_ip_prefixes = {
      "ippre-ldo-uks-tst-001" = { prefix_length = 30 }
    }
    public_ips = {
      "pip-from-prefix" = { prefix_key = "ippre-ldo-uks-tst-001" }
    }
  }

  assert {
    condition     = length(azurerm_public_ip_prefix.this) == 1 && length(azurerm_public_ip.this) == 1
    error_message = "A prefix and a public IP allocated from it should both be created."
  }
}

run "exposes_zipmaps" {
  command = plan

  assert {
    condition     = output.public_ip_ids_zipmap["pip-ldo-uks-tst-001"].name == "pip-ldo-uks-tst-001"
    error_message = "public_ip_ids_zipmap should map each name to a { name, id } object."
  }
}

run "rejects_standard_sku_with_dynamic_allocation" {
  command = plan

  variables {
    public_ips = {
      "pip-bad" = { allocation_method = "Dynamic" } # sku defaults to Standard
    }
  }

  expect_failures = [var.public_ips]
}

run "rejects_prefix_key_and_prefix_id_together" {
  command = plan

  variables {
    public_ips = {
      "pip-bad" = {
        prefix_key          = "ippre-x"
        public_ip_prefix_id = "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.Network/publicIPPrefixes/ippre-y"
      }
    }
  }

  expect_failures = [var.public_ips]
}

run "rejects_invalid_prefix_length" {
  command = plan

  variables {
    public_ip_prefixes = {
      "ippre-bad" = { prefix_length = 40 }
    }
    public_ips = {}
  }

  expect_failures = [var.public_ip_prefixes]
}
