
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
