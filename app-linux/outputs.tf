
output "outbound_ip_address_list" {
  value = azurerm_linux_web_app.app.outbound_ip_address_list
}

output "app_id" {
  value = azurerm_linux_web_app.app.id
}

output "hostname" {
  value = azurerm_linux_web_app.app.default_hostname
}

output "app_service_name" {
  value = azurerm_linux_web_app.app.name
}

output "app_service_user" {
  value = local.app_service_user
}

output "app_service_password" {
  value = local.app_service_password
}

output "identity" {
    value = azurerm_linux_web_app.app.identity
}

output "log_analytics_workspace_id" {
    value = local.log_analytics_workspace_id
}

output "log_analytics_primary_shared_key" {
    value     = join("", azurerm_log_analytics_workspace.log.*.primary_shared_key)
    sensitive = true
}