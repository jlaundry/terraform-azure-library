
terraform {
  required_providers {
    github = {
      source = "integrations/github"
    }
  }
}

locals {
  app_service_host     = azurerm_app_service.app.name
  app_service_user     = azurerm_app_service.app.site_credential[0].username
  app_service_password = azurerm_app_service.app.site_credential[0].password

  instance_name = "${var.name}-${lower(var.env)}-${lower(replace(var.location, " ", ""))}-${random_id.instance_id.hex}"

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
      azurerm_app_service.app.outbound_ip_address_list,
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
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set",
  ]
}

resource "azurerm_key_vault_access_policy" "kva_app" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = azurerm_app_service.app.identity.0.tenant_id
  object_id    = azurerm_app_service.app.identity.0.principal_id

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
  allow_blob_public_access = false

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

data "azurerm_app_service_plan" "asp" {
  name                = var.app_service_plan_name
  resource_group_name = var.app_service_plan_rg_name
}

resource "azurerm_app_service" "app" {
  name                = "app-${local.instance_name}"
  location            = var.location
  resource_group_name = local.resource_group_name
  app_service_plan_id = data.azurerm_app_service_plan.asp.id

  site_config {
    linux_fx_version         = var.linux_fx_version
    ftps_state               = "Disabled"
    min_tls_version          = "1.2"
  }

  https_only = true

  app_settings = merge(
    {
      "APPINSIGHTS_INSTRUMENTATIONKEY" = azurerm_application_insights.appi.instrumentation_key
      "APPLICATIONINSIGHTS_CONNECTION_STRING"  = azurerm_application_insights.appi.connection_string
      "DATABASE_URL" = "@Microsoft.KeyVault(SecretUri=https://${local.kv_name}.vault.azure.net/secrets/${local.kv_database_url_name}/)"
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


# data "azurerm_dns_zone" "zone" {
#   name                = var.zone_name
#   resource_group_name = var.zone_resource_group_name
# }

# resource "azurerm_dns_cname_record" "app" {
#   name                = "${var.application_name}.${var.env}"
#   zone_name           = data.azurerm_dns_zone.zone.name
#   resource_group_name = data.azurerm_dns_zone.zone.resource_group_name
#   ttl                 = 60
#   record              = azurerm_app_service.app.default_site_hostname
# }

# resource "azurerm_dns_txt_record" "asuid" {
#   name                = "asuid.${azurerm_dns_cname_record.app.name}"
#   zone_name           = data.azurerm_dns_zone.zone.name
#   resource_group_name = data.azurerm_dns_zone.zone.resource_group_name
#   ttl                 = 60

#   record {
#     value = azurerm_app_service.app.custom_domain_verification_id
#   } 
# }

# resource "azurerm_app_service_custom_hostname_binding" "app" {
#   hostname            = "${azurerm_dns_cname_record.app.name}.${azurerm_dns_cname_record.app.zone_name}"
#   app_service_name    = azurerm_app_service.app.name
#   resource_group_name = azurerm_app_service.app.resource_group_name

#   depends_on = [
#     azurerm_dns_txt_record.asuid
#   ]
# }

# resource "azurerm_app_service_managed_certificate" "app" {
#   custom_hostname_binding_id = azurerm_app_service_custom_hostname_binding.app.id
# }

# resource "azurerm_app_service_certificate_binding" "app" {
#   hostname_binding_id = azurerm_app_service_custom_hostname_binding.app.id
#   certificate_id      = azurerm_app_service_managed_certificate.app.id
#   ssl_state           = "SniEnabled"
# }
