resource "azapi_resource" "ipam_pool" {
  type = "Microsoft.Network/networkManagers/ipamPools@2024-05-01"
  body = {
    properties = {
      addressPrefixes = var.address_prefixes
      description     = var.description
      parentPoolName  = var.parent_pool_name
      displayName     = var.display_name
    }
    tags = var.tags
  }
  location                  = var.location
  name                      = var.name
  parent_id                 = var.network_manager_id
  schema_validation_enabled = false
}

resource "azapi_resource" "static_cidr" {
  for_each = var.static_cidr_map

  type = "Microsoft.Network/networkManagers/ipamPools/staticCidrs@2024-05-01"
  body = {
    properties = {
      addressPrefixes = each.value.address_prefixes
      description     = each.value.description
    }
  }
  name                      = each.value.name
  parent_id                 = azapi_resource.ipam_pool.id
  schema_validation_enabled = false
}

resource "time_sleep" "wait_lock" {
  destroy_duration = "10s"

  depends_on = [azapi_resource.ipam_pool]
}

resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azapi_resource.ipam_pool.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."

  depends_on = [time_sleep.wait_lock]
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  principal_id                           = each.value.principal_id
  scope                                  = azapi_resource.ipam_pool.id
  condition                              = each.value.condition
  condition_version                      = each.value.condition_version
  delegated_managed_identity_resource_id = each.value.delegated_managed_identity_resource_id
  principal_type                         = each.value.principal_type
  role_definition_id                     = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? each.value.role_definition_id_or_name : null
  role_definition_name                   = strcontains(lower(each.value.role_definition_id_or_name), lower(local.role_definition_resource_substring)) ? null : each.value.role_definition_id_or_name
  skip_service_principal_aad_check       = each.value.skip_service_principal_aad_check
}
