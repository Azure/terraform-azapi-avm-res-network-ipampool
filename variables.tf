variable "network_manager_id" {
  type        = string
  description = "The ID of Azure Network Manager where the IPAM Pool resource should be deployed."
  nullable    = false
}

variable "location" {
  type        = string
  description = "Azure region where the resource should be deployed."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name of the Network Manager IPAM Pool resource resource."

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,64}$", var.name))
    error_message = "The name must be between 1 and 64 characters long and can only contain letters, numbers and hyphen(-)."
  }
}

variable "address_prefixes" {
  type        = list(string)
  description = "The address prefixes for the the Network Manager IPAM Pool resource"

  validation {
    condition = alltrue([
      for v in var.address_prefixes :
      can(cidrhost(v, 0))
    ])
    error_message = "The address_prefixes must be validate IPv4 CIDR or IPv6 CIDR"
  }
}

variable "description" {
  type        = string
  description = "The description for the the Network Manager IPAM Pool resource"
  nullable    = true
}

variable "parent_pool_name" {
  type        = string
  description = "The parent pool name for the the Network Manager IPAM Pool resource"
  nullable    = true
}

variable "display_name" {
  type        = string
  description = "The display name for the the Network Manager IPAM Pool resource"
  nullable    = true
}

variable "static_cidr_map" {
  type = map(object({
    name             = string
    address_prefixes = list(string)
    description      = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of Static CIDR to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `name` - (Optional) The name of the Static CIDR.
- `address_prefixes` - (Optional) A list of address prefixes for the Static CIDR.
- `description` - (Optional) The description for the Static CIDR.
DESCRIPTION
  nullable    = false

  validation {
    condition = alltrue(flatten([
      for v in var.static_cidr_map : [
        for u in v.address_prefixes :
        can(cidrhost(u, 0))
      ]
    ]))
    error_message = "The address_prefixes must be validate IPv4 CIDR or IPv6 CIDR"
  }
}

# required AVM interfaces
# remove only if not supported by the resource
# tflint-ignore: terraform_unused_declarations
variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
Controls the Resource Lock configuration for this resource. The following properties can be specified:

- `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
- `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "The lock level must be one of: 'None', 'CanNotDelete', or 'ReadOnly'."
  }
}

variable "role_assignments" {
  type = map(object({
    role_definition_id_or_name             = string
    principal_id                           = string
    description                            = optional(string, null)
    skip_service_principal_aad_check       = optional(bool, false)
    condition                              = optional(string, null)
    condition_version                      = optional(string, null)
    delegated_managed_identity_resource_id = optional(string, null)
  }))
  default     = {}
  description = <<DESCRIPTION
A map of role assignments to create on this resource. The map key is deliberately arbitrary to avoid issues where map keys maybe unknown at plan time.

- `role_definition_id_or_name` - The ID or name of the role definition to assign to the principal.
- `principal_id` - The ID of the principal to assign the role to.
- `description` - The description of the role assignment.
- `skip_service_principal_aad_check` - If set to true, skips the Azure Active Directory check for the service principal in the tenant. Defaults to false.
- `condition` - The condition which will be used to scope the role assignment.
- `condition_version` - The version of the condition syntax. Valid values are '2.0'.

> Note: only set `skip_service_principal_aad_check` to true if you are assigning a role to a service principal.
DESCRIPTION
  nullable    = false
}

# tflint-ignore: terraform_unused_declarations
variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}
