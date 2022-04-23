
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.2.0"
    }
    github = {
      source = "integrations/github"
    }
  }
}

locals {
  app_service_host     = azurerm_linux_web_app.app.name
  app_service_user     = azurerm_linux_web_app.app.site_credential[0].name
  app_service_password = azurerm_linux_web_app.app.site_credential[0].password

  instance_name = "${var.name}-${local.suffix}-${random_id.instance_id.hex}"

  kv_appinsights_instrumentationkey_name = "appinsightsikey"
  kv_appinsights_connection_string_name  = "appiconnectionstr"
  kv_database_url_name      = "databaseurl"
  kv_django_secret_key_name = "djangosecretkey"
  kv_name                   = "kv${substr(replace(local.instance_name, "-", ""), 0, 14)}${random_id.instance_id.hex}"

  resource_group_name = var.resource_group_name != "" ? var.resource_group_name : azurerm_resource_group.rg[0].name
  suffix       = "${lower(var.env)}-${lower(replace(var.location, " ", ""))}"
}

data "azurerm_client_config" "current" {
}

data "github_repository" "repo" {
  full_name = var.repository_name
}

resource "random_id" "instance_id" {
  byte_length = 4
}

resource "azurerm_resource_group" "rg" {
  count    = var.resource_group_name == "" ? 1 : 0

  name     = "rg-${var.name}-${local.suffix}"
  location = var.location

  tags = var.tags
}

resource "random_password" "django_secret_key" {
  length  = 64
  special = false
}

# TODO move to separate kv module?
resource "azurerm_key_vault" "kv" {
  name                        = local.kv_name
  resource_group_name         = local.resource_group_name
  location                    = var.location

  enabled_for_disk_encryption = false
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true

  network_acls {
    bypass         = "None"
    default_action = "Deny"
    ip_rules       = concat(
      var.ip_allowlist,
      azurerm_linux_web_app.app.outbound_ip_address_list,
    )
  }

  sku_name = "standard"

  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "kva_current" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore",
  ]
}

resource "azurerm_key_vault_access_policy" "kva_app" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = azurerm_linux_web_app.app.identity.0.tenant_id
  object_id    = azurerm_linux_web_app.app.identity.0.principal_id

  secret_permissions = [
    "Get",
    "List",
  ]
}

resource "azurerm_key_vault_secret" "appinsights_connection_string" {
  key_vault_id = azurerm_key_vault.kv.id
  name         = local.kv_appinsights_connection_string_name
  value        = azurerm_application_insights.appi.connection_string

  depends_on = [
    azurerm_key_vault_access_policy.kva_current,
  ]
}

resource "azurerm_key_vault_secret" "database_url" {
  key_vault_id = azurerm_key_vault.kv.id
  name         = local.kv_database_url_name
  value        = var.database_url

  depends_on = [
    azurerm_key_vault_access_policy.kva_current,
  ]
}

resource "azurerm_key_vault_secret" "django_secret_key" {
  key_vault_id = azurerm_key_vault.kv.id
  name         = local.kv_django_secret_key_name
  value        = random_password.django_secret_key.result

  depends_on = [
    azurerm_key_vault_access_policy.kva_current,
  ]
}

resource "azurerm_storage_account" "app" {
  name                     = "st${substr(replace(local.instance_name, "-", ""), 0, 14)}${random_id.instance_id.hex}"
  resource_group_name      = local.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  min_tls_version = "TLS1_2"
  allow_nested_items_to_be_public = false

  tags = var.tags
}

resource "azurerm_application_insights" "appi" {
  name                = "appi-${local.instance_name}"
  location            = var.location
  resource_group_name = local.resource_group_name
  application_type    = "web"

  retention_in_days   = 90

  tags = var.tags
}

data "azurerm_service_plan" "asp" {
  name                = var.app_service_plan_name
  resource_group_name = var.app_service_plan_rg_name
}

resource "azurerm_linux_web_app" "app" {
  name                = "app-${local.instance_name}"
  location            = var.location
  resource_group_name = local.resource_group_name
  service_plan_id     = data.azurerm_service_plan.asp.id

  site_config {
    application_stack {
      python_version          = lookup(var.application_stack, "python_version", null)
    }

    always_on                              = true
    ftps_state                             = "Disabled"
    scm_minimum_tls_version                = "1.2"
  }

  https_only = true

  app_settings = merge(
    {
      "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.appi.instrumentation_key
      "APPLICATIONINSIGHTS_CONNECTION_STRING"  = azurerm_application_insights.appi.connection_string
      "DATABASE_URL" = "@Microsoft.KeyVault(SecretUri=https://${local.kv_name}.vault.azure.net/secrets/${local.kv_database_url_name}/)"
      "KUDU_BUILD_VERSION" = "1.0.0"
      "SCM_DO_BUILD_DURING_DEPLOYMENT" = "true"
      "SECRET_KEY" = "@Microsoft.KeyVault(SecretUri=https://${local.kv_name}.vault.azure.net/secrets/${local.kv_django_secret_key_name}/)"
      # "WEBSITE_RUN_FROM_PACKAGE" = "1"
      "WEBSITE_WEBDEPLOY_USE_SCM" = "true"  # Needed for package deployment
      #"DEBUG" = "true"
    },
    var.app_settings,
  )

  identity {
    type = "SystemAssigned"
  }

  # logs {
  #   http_logs {
  #     azure_blob_storage {
  #       sas_url = ""
  #       retention_in_days = "90"
  #     }
  #   }
  # }

  # connection_string {
  #   name  = "db"
  #   type  = "PostgreSQL"
  #   value = var.connection_string
  # }

  tags = var.tags
}

resource "github_actions_secret" "azure_app_service_name" {
  repository       = data.github_repository.repo.name
  secret_name      = "${upper(var.env)}_AZURE_APP_SERVICE_NAME"
  plaintext_value  = local.app_service_host
}

resource "github_actions_secret" "azure_publish_profile" {
  repository       = data.github_repository.repo.name
  secret_name      = "${upper(var.env)}_AZURE_PUBLISH_PROFILE"
  plaintext_value  = templatefile("${path.module}/publish.xml.tmpl", {
    host = local.app_service_host
    user = local.app_service_user
    password = local.app_service_password
  })
}


data "azurerm_dns_zone" "zone" {
  count               = var.zone_name == "" ? 0 : 1

  name                = var.zone_name
  resource_group_name = var.zone_resource_group_name
}

resource "azurerm_dns_cname_record" "app" {
  count               = var.zone_name == "" ? 0 : 1

  name                = "${var.name}.${var.env}"
  zone_name           = data.azurerm_dns_zone.zone[0].name
  resource_group_name = data.azurerm_dns_zone.zone[0].resource_group_name
  ttl                 = 60
  record              = azurerm_linux_web_app.app.default_hostname
}

resource "azurerm_dns_txt_record" "asuid" {
  count               = var.zone_name == "" ? 0 : 1

  name                = "asuid.${azurerm_dns_cname_record.app[0].name}"
  zone_name           = data.azurerm_dns_zone.zone[0].name
  resource_group_name = data.azurerm_dns_zone.zone[0].resource_group_name
  ttl                 = 60

  record {
    value = azurerm_linux_web_app.app.custom_domain_verification_id
  } 
}

resource "azurerm_app_service_custom_hostname_binding" "app" {
  count               = var.zone_name == "" ? 0 : 1

  hostname            = "${azurerm_dns_cname_record.app[0].name}.${azurerm_dns_cname_record.app[0].zone_name}"
  app_service_name    = azurerm_linux_web_app.app.name
  resource_group_name = azurerm_linux_web_app.app.resource_group_name

  depends_on = [
    azurerm_dns_cname_record.app[0],
    azurerm_dns_txt_record.asuid[0]
  ]
}

resource "azurerm_app_service_managed_certificate" "app" {
  count               = var.zone_name == "" ? 0 : 1

  custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.app[0].id
}

resource "azurerm_app_service_certificate_binding" "app" {
  count               = var.zone_name == "" ? 0 : 1

  hostname_binding_id = azurerm_app_service_custom_hostname_binding.app[0].id
  certificate_id      = azurerm_app_service_managed_certificate.app[0].id
  ssl_state           = "SniEnabled"
}
