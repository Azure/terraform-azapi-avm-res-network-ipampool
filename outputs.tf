output "ipam_pool_id" {
  description = <<DESCRIPTION
The resource ID of the Network Manager IPAM Pool created.
  DESCRIPTION
  value       = azapi_resource.ipam_pool.id
}

output "static_cidr_ids" {
  description = <<DESCRIPTION
A list of resource IDs of the Network Manager Static CIDR created.
  DESCRIPTION
  value = [
    for v in azapi_resource.static_cidr :
    v.id
  ]
}
