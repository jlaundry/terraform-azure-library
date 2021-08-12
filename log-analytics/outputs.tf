
output "id" {
    value = azurerm_log_analytics_workspace.log.id
}

output "instance_id" {
    value = local.instance_id
}

output "name" {
    value = azurerm_log_analytics_workspace.log.name
}

output "resource_group_name" {
    value = local.resource_group_name
}
