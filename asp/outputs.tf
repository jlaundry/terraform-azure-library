
output "name" {
   value = azurerm_service_plan.asp.name
}

output "resource_group_name" {
  value = local.resource_group_name
}
