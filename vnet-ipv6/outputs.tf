
output "prefix" {
    value = local.ipv6_prefix
}

output "network" {
    value = local.ipv6_network
}

output "resource_group_name" {
    value = local.resource_group_name
}

output "subnets" {
  value = tomap({
    for key, value in var.subnets : key => azurerm_subnet.subnet[key].id
  })
}
