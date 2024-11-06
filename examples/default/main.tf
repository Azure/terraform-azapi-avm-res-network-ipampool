terraform {
  required_version = "~> 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.74"
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

data "azurerm_subscription" "current" {}

resource "azurerm_network_manager" "example" {
  location            = azurerm_resource_group.example.location
  name                = "example-vnet-manager"
  resource_group_name = azurerm_resource_group.example.name
  scope_accesses      = ["Connectivity", "SecurityAdmin"]

  scope {
    subscription_ids = [data.azurerm_subscription.current.id]
  }
}

# This is the module call
# Do not specify location here due to the randomization above.
# Leaving location as `null` will cause the module to use the resource group location
# with a data source.
module "ipampool" {
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
