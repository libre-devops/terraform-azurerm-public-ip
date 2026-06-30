<!--
  This is the template for every Libre DevOps Terraform module. When you create a module from it:
    - replace the title, tagline, and the CI workflow / repo name in the badge URLs
    - replace the resources in main.tf, and the variables, outputs, and examples to match
    - run `just docs` (or Sort-LdoTerraform.ps1) to regenerate the section between the markers
-->
<!--
  Keep the title and badges OUTSIDE the centered <div>: the Terraform Registry's markdown renderer
  does not parse markdown inside an HTML block, so a # heading or [![badge]] in the div renders as
  literal text on the registry. Only the logo (HTML) goes in the div.
-->
<div align="center">
  <a href="https://libredevops.org">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://libredevops.org/assets/libre-devops-white.png">
      <img alt="Libre DevOps" src="https://libredevops.org/assets/libre-devops-black.png" width="300">
    </picture>
  </a>
</div>

# Terraform Azure Public IP

Creates Azure public IPs and public IP prefixes, with secure defaults and in-module prefix allocation.

[![CI](https://github.com/libre-devops/terraform-azurerm-public-ip/actions/workflows/ci.yml/badge.svg)](https://github.com/libre-devops/terraform-azurerm-public-ip/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/libre-devops/terraform-azurerm-public-ip?sort=semver&label=release)](https://github.com/libre-devops/terraform-azurerm-public-ip/releases/latest)
[![Terraform Registry](https://img.shields.io/badge/registry-libre--devops-7B42BC?logo=terraform&logoColor=white)](https://registry.terraform.io/namespaces/libre-devops)
[![License](https://img.shields.io/github/license/libre-devops/terraform-azurerm-public-ip)](./LICENSE)

---

## Overview

Public IPs and public IP prefixes from keyed maps (stable `for_each`). The resource group is passed by
id and parsed. **Secure defaults**: Standard SKU with Static allocation (Basic is retired and Standard
requires Static). A public IP can allocate from a prefix created in the same module via `prefix_key`,
or from an external prefix via `public_ip_prefix_id`. Covers the full `azurerm_public_ip` and
`azurerm_public_ip_prefix` surface (zones, sku_tier, DDoS mode, DNS label, IP tags, idle timeout, ...).

## Usage

```hcl
module "public_ip" {
  source  = "libre-devops/public-ip/azurerm"
  version = "~> 4.0"

  resource_group_id = module.rg.ids["rg-ldo-uks-prd-001"]
  location          = "uksouth"
  tags              = module.tags.tags

  public_ip_prefixes = {
    "ippre-ldo-uks-prd-001" = { prefix_length = 30, zones = ["1", "2", "3"] }
  }

  public_ips = {
    "pip-ldo-uks-prd-001" = { prefix_key = "ippre-ldo-uks-prd-001" } # allocated from the prefix above
    "pip-ldo-uks-prd-002" = { zones = ["1", "2", "3"] }
  }
}
```

## Examples

- [`examples/minimal`](./examples/minimal) - one Standard static public IP.
- [`examples/complete`](./examples/complete) - a zone-redundant prefix, an IP allocated from it, and a
  standalone zonal IP.

## Developing

Local work needs **PowerShell 7+** and **[`just`](https://github.com/casey/just)**, because the recipes
wrap the [LibreDevOpsHelpers](https://www.powershellgallery.com/packages/LibreDevOpsHelpers)
PowerShell module (the same engine the `libre-devops/terraform-azure` action runs in CI). Install
just with `brew install just`, or `uv tool add rust-just` then `uv run just <recipe>`.

Run `just` to list recipes: `just update-ldo-pwsh` (install or force-update LibreDevOpsHelpers from
PSGallery), `just validate`, `just scan` (Trivy only), `just pwsh-analyze` (PSScriptAnalyzer only),
`just plan`, `just apply`, `just destroy`, `just e2e`, `just test`, and `just docs` (the
plan/apply/destroy recipes mirror the action, including the storage firewall dance; `just e2e`
applies an example then always destroys it, defaulting to `minimal`, so nothing is left running).
Releasing is also `just`:
`just increment-release [patch|minor|major]` bumps, tags, and publishes a GitHub release, and the
Terraform Registry picks up the tag.

## Security scan exceptions

This module is scanned with [Trivy](https://github.com/aquasecurity/trivy); HIGH and CRITICAL
findings fail the build. Any waiver is a deliberate, reviewed decision, never a way to quiet a
finding that should be fixed. Waivers live in [`.trivyignore.yaml`](./.trivyignore.yaml) (the
machine-applied source of truth, passed to Trivy with `--ignorefile`) and are mirrored in the table
below so the reason is auditable.

| Trivy ID | Resource | Finding | Justification |
|----------|----------|---------|---------------|
| _None_   |          |         |               |

To add an exception: add an entry to `.trivyignore.yaml` (`id`, optional `paths` to scope it, and a
`statement` recording why), then add a matching row here. Where the finding is out of this module's
scope, point the justification at the Libre DevOps module that does address it (for example the
private-endpoint module). Both the file and this table are reviewed in the pull request.

## Reference

The Requirements, Providers, Inputs, Outputs, and Resources below are generated by `terraform-docs`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0, < 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_public_ip_prefix.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip_prefix) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | Azure region for the public IPs and prefixes. | `string` | n/a | yes |
| <a name="input_public_ip_prefixes"></a> [public\_ip\_prefixes](#input\_public\_ip\_prefixes) | Public IP prefixes to create, keyed by name. A public IP can draw from one of these in the same<br/>module via its prefix\_key. Defaults to a Standard regional IPv4 /28. | <pre>map(object({<br/>    prefix_length = optional(number, 28)<br/>    sku           = optional(string, "Standard")<br/>    sku_tier      = optional(string, "Regional")<br/>    ip_version    = optional(string, "IPv4")<br/>    zones         = optional(list(string), [])<br/>    tags          = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_public_ips"></a> [public\_ips](#input\_public\_ips) | Public IPs to create, keyed by name. Secure defaults: Standard SKU with Static allocation (Basic is<br/>retired and Standard requires Static). Set prefix\_key to allocate from a public\_ip\_prefixes entry in<br/>this module, or public\_ip\_prefix\_id for an external prefix (not both). | <pre>map(object({<br/>    allocation_method       = optional(string, "Static")<br/>    sku                     = optional(string, "Standard")<br/>    sku_tier                = optional(string, "Regional")<br/>    ip_version              = optional(string, "IPv4")<br/>    zones                   = optional(list(string), [])<br/>    idle_timeout_in_minutes = optional(number, 4)<br/>    domain_name_label       = optional(string)<br/>    domain_name_label_scope = optional(string)<br/>    reverse_fqdn            = optional(string)<br/>    prefix_key              = optional(string)<br/>    public_ip_prefix_id     = optional(string)<br/>    ddos_protection_mode    = optional(string, "VirtualNetworkInherited")<br/>    ddos_protection_plan_id = optional(string)<br/>    edge_zone               = optional(string)<br/>    ip_tags                 = optional(map(string), {})<br/>    tags                    = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | Resource id of the resource group to create the public IPs and prefixes in. The name and subscription are parsed from it (pass the rg module's ids output). | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to every public IP and prefix (merged with any per-resource tags). | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_public_ip_addresses"></a> [public\_ip\_addresses](#output\_public\_ip\_addresses) | Map of public IP name to its allocated IP address. |
| <a name="output_public_ip_fqdns"></a> [public\_ip\_fqdns](#output\_public\_ip\_fqdns) | Map of public IP name to its FQDN (only when domain\_name\_label is set). |
| <a name="output_public_ip_ids"></a> [public\_ip\_ids](#output\_public\_ip\_ids) | Map of public IP name to its id. |
| <a name="output_public_ip_ids_zipmap"></a> [public\_ip\_ids\_zipmap](#output\_public\_ip\_ids\_zipmap) | Map of public IP name to a { name, id } object, for handing the whole object downstream. |
| <a name="output_public_ip_prefix_cidrs"></a> [public\_ip\_prefix\_cidrs](#output\_public\_ip\_prefix\_cidrs) | Map of public IP prefix name to its allocated CIDR (ip\_prefix). |
| <a name="output_public_ip_prefix_ids"></a> [public\_ip\_prefix\_ids](#output\_public\_ip\_prefix\_ids) | Map of public IP prefix name to its id. |
| <a name="output_public_ip_prefix_ids_zipmap"></a> [public\_ip\_prefix\_ids\_zipmap](#output\_public\_ip\_prefix\_ids\_zipmap) | Map of public IP prefix name to a { name, id } object. |
| <a name="output_public_ip_prefixes"></a> [public\_ip\_prefixes](#output\_public\_ip\_prefixes) | The full azurerm\_public\_ip\_prefix resources, keyed by name. |
| <a name="output_public_ips"></a> [public\_ips](#output\_public\_ips) | The full azurerm\_public\_ip resources, keyed by name. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource group name parsed from resource\_group\_id. |
| <a name="output_subscription_id"></a> [subscription\_id](#output\_subscription\_id) | Subscription id parsed from resource\_group\_id. |
<!-- END_TF_DOCS -->
