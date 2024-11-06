<!-- BEGIN_TF_DOCS -->
# Default example

This deploys the module in its simplest form.

```hcl
terraform {
  required_version = "~> 1.5"
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = "~> 2.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.74"
    }
    modtm = {
      source  = "azure/modtm"
      version = "~> 0.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

provider "azurerm" {
  features {}
}

## Section to provide a random Azure region for the resource group
# This allows us to randomize the region for the resource group.
module "regions" {
  source  = "Azure/avm-utl-regions/azurerm"
  version = "~> 0.1"
}

# This allows us to randomize the region for the resource group.
resource "random_integer" "region_index" {
  max = length(module.regions.regions) - 1
  min = 0
}
## End of section to provide a random Azure region for the resource group

# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.3"
}

# This is required for resource modules
resource "azurerm_resource_group" "example" {
  location = module.regions.regions[random_integer.region_index.result].name
  name     = module.naming.resource_group.name_unique
}

data "azurerm_subscription" "current" {
}

resource "azurerm_network_manager" "example" {
  name                = "example-vnet-manager"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  scope {
    subscription_ids = [data.azurerm_subscription.current.id]
  }
  scope_accesses = ["Connectivity", "SecurityAdmin"]
}

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "test" {
  source = "../../"
  # source             = "Azure/avm-network-ipampool/azapi"
  location           = azurerm_resource_group.example.location
  network_manager_id = azurerm_network_manager.example.id
  name               = var.name
  address_prefixes   = var.address_prefixes
  parent_pool_name   = var.parent_pool_name
  display_name       = var.display_name
  description        = var.description
  static_cidr_map    = var.static_cidr_map
  tags               = var.tags
  enable_telemetry   = var.enable_telemetry # see variables.tf
  lock               = var.lock
  role_assignments   = var.role_assignments
}
```

<!-- markdownlint-disable MD033 -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.5)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.74)

- <a name="requirement_azapi"></a> [azapi](#requirement\_azapi) (~> 2.0)

- <a name="requirement_modtm"></a> [modtm](#requirement\_modtm) (~> 0.3)

- <a name="requirement_random"></a> [random](#requirement\_random) (~> 3.5)

## Resources

The following resources are used by this module:

- [azapi_resource.ipam_pool](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) (resource)
- [azapi_resource.static_cidr](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) (resource)
- [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) (resource)
- [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [modtm_telemetry.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/resources/telemetry) (resource)
- [random_uuid.telemetry](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) (resource)
- [azurerm_client_config.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)
- [modtm_module_source.telemetry](https://registry.terraform.io/providers/azure/modtm/latest/docs/data-sources/module_source) (data source)

<!-- markdownlint-disable MD013 -->
## Required Inputs

The following input variables are required (have default values):

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the Network Manager IPAM Pool resource.

Type: `string`

### <a name="input_network_manager_id"></a> [network_manager_id](#input\_network\_manager\_id)

Description: The ID of Azure Network Manager where the IPAM Pool resource should be deployed.

Type: `string`

### <a name="input_location"></a> [location](#input\_location)

Description: Azure region where the resource should be deployed.

Type: `string`

### <a name="input_address_prefixes"></a> [address_prefixes](#input\_address\_prefixes)

Description: The address prefixes of the Network Manager IPAM Pool resource.

Type: `list(string)`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_description"></a> [description](#input\_description)

Description: The description of the Network Manager IPAM Pool resource.

Type: `string`

### <a name="input_parent_pool_name"></a> [parent_pool_name](#input\_parent\_pool\_name)

Description: The parent pool name of the Network Manager IPAM Pool resource.

Type: `string`

### <a name="input_display_name"></a> [display_name](#input\_display\_name)

Description: The display name of the Network Manager IPAM Pool resource.

Type: `string`

### <a name="input_static_cidr"></a> [static_cidr](#input\static\_cidr)

Description: A map of Static CIDR to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the Static CIDR.
- `address_prefixes` - (Optional) A list of address prefixes for the Static CIDR.
- `description` - (Optional) The description for the Static CIDR.
DESCRIPTION

Type:
```hcl
map(object({
  name             = string
  address_prefixes = list(string)
  description      = optional(string, null)
}))
```


Default: `{}`

### <a name="input_enable_telemetry"></a> [enable\_telemetry](#input\_enable\_telemetry)

Description: This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.

Type: `bool`

Default: `true`

### <a name="input_lock"></a> [lock](#input\_lock)

Description: Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.

Type:
```hcl
object({
  kind = string
  name = optional(string, null)
})
```

Default: `null`

### <a name="input_role_assignments"></a> [role_assignments](#input\_role\_assignments)

Description: A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.

Type:
```hcl
map(object({
  role_definition_id_or_name             = string
  principal_id                           = string
  description                            = optional(string, null)
  skip_service_principal_aad_check       = optional(bool, false)
  condition                              = optional(string, null)
  condition_version                      = optional(string, null)
  delegated_managed_identity_resource_id = optional(string, null)
}))
```

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Tags of the resource.

Type: `map(string)`

Default: `null`

## Outputs

### <a name="output_ipam_pool_id"></a> [ipam_pool_id](#output\_ipam\_pool\_id)

Description: The resource ID of the Network Manager IPAM Pool created.

Type: `string`

### <a name="static_cidr_ids"></a> [static_cidr_ids](#output\_static\_cidr\_ids)

A list of resource IDs of the Network Manager Static CIDR created.

Type: `list(string)`


## Modules

The following Modules are called:

### <a name="module_naming"></a> [naming](#module\_naming)

Source: Azure/naming/azurerm

Version: ~> 0.3

### <a name="module_regions"></a> [regions](#module\_regions)

Source: Azure/avm-utl-regions/azurerm

Version: ~> 0.1

<!-- markdownlint-disable-next-line MD041 -->
## Data Collection

The software may collect information about you and your use of the software and send it to Microsoft. Microsoft may use this information to provide services and improve our products and services. You may turn off the telemetry as described in the repository. There are also some features in the software that may enable you and Microsoft to collect data from users of your applications. If you use these features, you must comply with applicable law, including providing appropriate notices to users of your applications together with a copy of Microsoft’s privacy statement. Our privacy statement is located at <https://go.microsoft.com/fwlink/?LinkID=824704>. You can learn more about data collection and use in the help documentation and our privacy statement. Your use of the software operates as your consent to these practices.
<!-- END_TF_DOCS -->
