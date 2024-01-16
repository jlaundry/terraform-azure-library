
output "identity" {
    value = azurerm_linux_function_app.func.identity
}

output "function_app_name" {
    value = azurerm_linux_function_app.func.name
}

output "log_analytics_workspace_id" {
    value = azurerm_log_analytics_workspace.log.workspace_id
}

output "log_analytics_primary_shared_key" {
    value     = azurerm_log_analytics_workspace.log.primary_shared_key
    sensitive = true
}