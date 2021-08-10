
output "database_url" {
  value = "mssql://${azuread_application.app.application_id}:${azuread_service_principal_password.db_password.value}@${data.azurerm_mssql_server.sql.fully_qualified_domain_name}:1433/${azurerm_mssql_database.db.name}"
  sensitive = true
}

output "sql_create_user" {
  value = "Run on ${data.azurerm_mssql_server.sql.name}/${azurerm_mssql_database.db.name}: CREATE USER [${azuread_application.app.display_name}] FROM EXTERNAL PROVIDER; EXEC sp_addrolemember 'db_owner', [${azuread_application.app.display_name}];"
}
