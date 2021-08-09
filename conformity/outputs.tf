
output "tenant_id" {
    value = data.azuread_client_config.current.tenant_id
}

output "client_id" {
    value = azuread_application.conformity.application_id
}

output "client_secret" {
    value = random_password.conformity.result
    sensitive = true
}
