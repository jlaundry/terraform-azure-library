
output "principal_id" {
    value = azurerm_linux_function_app.func.identity.principal_id
}
