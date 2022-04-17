
terraform {
  required_providers {
    azuread = {
      source = "hashicorp/azuread"
      version = ">= 2.4.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.2.0"
    }
  }
}

locals {
    instance_name = "sql-${replace(var.sql_version, ".", "")}-${local.suffix}-${random_id.instance_id.hex}"
    resource_group_name = var.resource_group_name != "" ? var.resource_group_name : azurerm_resource_group.rg[0].name
    suffix  = "${lower(var.env)}-${lower(replace(var.location, " ", ""))}"
}

resource "random_id" "instance_id" {
  byte_length = 4

  keepers = {
    sql_version = var.sql_version
  }
}

resource "azurerm_resource_group" "rg" {
  count    = var.resource_group_name == "" ? 1 : 0

  name     = "rg-sql-${local.suffix}"
  location = var.location

  tags = var.tags
}

resource "random_password" "sa" {
  length           = 24
  special          = false
}

resource "azurerm_storage_account" "db" {
  name                     = "st${substr(replace(local.instance_name, "-", ""), 0, 14)}${random_id.instance_id.hex}"
  resource_group_name      = local.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version = "TLS1_2"
  allow_nested_items_to_be_public = false

  tags = var.tags
}

resource "azurerm_mssql_server" "db" {
  name                = local.instance_name
  location            = var.location
  resource_group_name = local.resource_group_name

  version                      = var.sql_version
  administrator_login          = "sa${random_id.instance_id.hex}"
  administrator_login_password = random_password.sa.result
  minimum_tls_version          = var.minimum_tls_version

  azuread_administrator {
    login_username = "aadadmin"
    tenant_id      = var.azure_tenant_id
    object_id      = var.administrator_object_id
  }

  identity {
    type           = "SystemAssigned"
  }

  tags = var.tags
}

# Managed Identity with Directory Reader required for Service Principal login
# https://docs.microsoft.com/en-us/azure/azure-sql/database/authentication-aad-service-principal

data "azuread_service_principal" "db" {
  display_name = azurerm_mssql_server.db.name
}

resource "azuread_directory_role" "directory_reader" {
  display_name = "Directory Readers"
}

resource "azuread_directory_role_member" "db_directory_reader" {
  role_object_id   = azuread_directory_role.directory_reader.object_id
  member_object_id = data.azuread_service_principal.db.object_id
}

# resource "azuread_group_member" "db" {
#   group_object_id  = var.sql_server_group_id
#   member_object_id = data.azuread_service_principal.db.object_id
# }

resource "azurerm_role_assignment" "db_storage" {
  scope                = azurerm_storage_account.db.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azuread_service_principal.db.object_id
}

resource "azurerm_mssql_firewall_rule" "ipfw" {
  for_each            = toset(var.ip_allowlist)

  name                = "ip-${replace(each.key, ".", "-")}"
  server_id           = azurerm_mssql_server.db.id

  start_ip_address    = each.value
  end_ip_address      = each.value
}

resource "azurerm_mssql_server_extended_auditing_policy" "audit" {
  server_id                               = azurerm_mssql_server.db.id
  storage_endpoint                        = azurerm_storage_account.db.primary_blob_endpoint
  # BUG: trying to create this with role assignment permission only fails with non-useful error
  storage_account_access_key              = azurerm_storage_account.db.primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = 7

  depends_on = [
    azurerm_role_assignment.db_storage
  ]
}

resource "azurerm_mssql_server_security_alert_policy" "alert" {
  resource_group_name = local.resource_group_name
  server_name         = azurerm_mssql_server.db.name
  state               = "Enabled"
}

resource "azurerm_storage_container" "scan" {
  name                  = "scan"
  storage_account_name  = azurerm_storage_account.db.name
  container_access_type = "private"
}

resource "azurerm_mssql_server_vulnerability_assessment" "scan" {
  server_security_alert_policy_id = azurerm_mssql_server_security_alert_policy.alert.id
  storage_container_path          = "${azurerm_storage_account.db.primary_blob_endpoint}${azurerm_storage_container.scan.name}/"
  # storage_account_access_key      = azurerm_storage_account.db.primary_access_key

  recurring_scans {
    enabled                   = true
    email_subscription_admins = true
    emails = [
      var.admin_email
    ]
  }

  depends_on = [
    azurerm_role_assignment.db_storage
  ]
}
