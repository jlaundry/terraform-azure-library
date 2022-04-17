
output "primary_blob_connection_string" {
  value = azurerm_storage_account.public.primary_blob_connection_string
}

output "storage_account_resource_id" {
  value = azurerm_storage_account.public.resource_id
}
