
terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "> 2.0.0"
    }
  }
}

locals {
  suffix = "${lower(var.env)}-${lower(replace(var.location, " ", ""))}"
}

data "azurerm_mssql_server" "sql" {
  name                = var.mssql_server_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_mssql_firewall_rule" "ipfw" {
  for_each            = toset(var.ip_allowlist)

  name                = "db-${var.db_name}-${replace(each.key, ".", "-")}"
  server_id           = data.azurerm_mssql_server.sql.id

  start_ip_address    = each.value
  end_ip_address      = each.value
}

resource "azurerm_mssql_database" "db" {
  name                = var.db_name
  server_id           = data.azurerm_mssql_server.sql.id

  sku_name            = var.sku_name

  tags = var.tags
}

resource "azurerm_mssql_database" "test_db" {
  count               = var.test_db_name == "" ? 0 : 1

  name                = var.test_db_name
  server_id           = data.azurerm_mssql_server.sql.id

  sku_name            = "Basic"

  tags = var.tags
}

resource "azuread_application" "app" {
  display_name         = "${data.azurerm_mssql_server.sql.name}_${var.db_name}"
}

resource "azuread_service_principal" "sp" {
  application_id       = azuread_application.app.application_id
}

resource "azuread_service_principal_password" "db_password" {
  service_principal_id = azuread_service_principal.sp.object_id
}
