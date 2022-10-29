
output "identity" {
    value = azurerm_linux_function_app.func.identity
}

output "function_app_name" {
    value = azurerm_linux_function_app.func.name
}
