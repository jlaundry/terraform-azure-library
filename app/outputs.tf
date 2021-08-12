
output "outbound_ip_address_list" {
  value = azurerm_app_service.app.outbound_ip_address_list
}

output "app_id" {
  value = azurerm_app_service.app.id
}

# output "hostname" {
#   value = azurerm_app_service_custom_hostname_binding.app.hostname
# }

output "app_service_name" {
  value = azurerm_app_service.app.name
}

output "app_service_user" {
  value = azurerm_app_service.app.site_credential[0].username
}

output "app_service_password" {
  value = azurerm_app_service.app.site_credential[0].password
}
