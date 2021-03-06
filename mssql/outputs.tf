
locals {
    user       = azurerm_mssql_server.db.administrator_login
    password   = azurerm_mssql_server.db.administrator_login_password
    fqdn       = azurerm_mssql_server.db.fully_qualified_domain_name
    port       = "1433"
}

output "database_url" {
  value = "mssql://${local.user}:${local.password}@${local.fqdn}:${local.port}"
  sensitive = true
}
