
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
  app_service_host     = azurerm_linux_function_app.func.name
  app_service_user     = azurerm_linux_function_app.func.site_credential[0].name
  app_service_password = azurerm_linux_function_app.func.site_credential[0].password

  instance_name        = "${lower(var.name)}-${local.suffix}-${random_id.instance_id.hex}"
  resource_group_name  = var.resource_group_name != "" ? var.resource_group_name : azurerm_resource_group.rg[0].name
  suffix               = var.suffix != "" ? var.suffix : "${lower(var.env)}-${lower(replace(var.location, " ", ""))}"
}

data "github_repository" "repo" {
  count    = var.github_repository_name == "" ? 0 : 1

  full_name = var.github_repository_name
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

resource "azurerm_log_analytics_workspace" "log" {
  name                = "log-${local.instance_name}"
  location            = var.location
  resource_group_name = local.resource_group_name
  sku                 = "PerGB2018"

  retention_in_days   = var.log_retention

  tags = var.tags
}

resource "azurerm_application_insights" "appi" {
  name                = "appi-${local.instance_name}"
  location            = var.location
  resource_group_name = local.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.log.id

  application_type    = "web"

  tags = var.tags
}

resource "azurerm_service_plan" "asp" {
  name                = "asp-${local.instance_name}"
  location            = var.location
  resource_group_name = local.resource_group_name

  os_type             = "Linux"
  sku_name            = "Y1"

  tags = var.tags
}

resource "azurerm_linux_function_app" "func" {
  name                = "func-${local.instance_name}"
  location            = var.location
  resource_group_name = local.resource_group_name
  service_plan_id     = azurerm_service_plan.asp.id

  storage_account_name       = azurerm_storage_account.app.name
  storage_account_access_key = azurerm_storage_account.app.primary_access_key

  https_only                 = true

  identity {
    type = "SystemAssigned"
  }

  dynamic "auth_settings" {
    for_each = var.auth_enabled ? [1] : []

    content {
      enabled = true

      dynamic "active_directory" {
        for_each = var.auth_aad_client_id == "" ? [] : [1]

        content {
          client_id     = var.auth_aad_client_id
          client_secret = var.auth_aad_client_secret
        }
      }
    }
  }

  app_settings = merge(
    {
      # FUNCTIONS_WORKER_RUNTIME = "python"
    },
    var.app_settings,
  )

  site_config {
    application_stack {
      powershell_core_version = lookup(var.application_stack, "powershell_core_version", null)
      python_version          = lookup(var.application_stack, "python_version", null)
    }

    application_insights_connection_string = azurerm_application_insights.appi.connection_string    # APPLICATIONINSIGHTS_CONNECTION_STRING
    application_insights_key               = azurerm_application_insights.appi.instrumentation_key  # APPINSIGHTS_INSTRUMENTATIONKEY
    ftps_state                             = "Disabled"
    scm_minimum_tls_version                = "1.2"
  }

  tags = var.tags
}

resource "github_actions_secret" "azure_app_service_name" {
  count    = var.github_repository_name == "" ? 0 : 1
  
  repository       = data.github_repository.repo[0].name
  secret_name      = "${upper(var.env)}_AZURE_APP_SERVICE_NAME"
  plaintext_value  = local.app_service_host
}

resource "github_actions_secret" "azure_publish_profile" {
  count    = var.github_repository_name == "" ? 0 : 1
  
  repository       = data.github_repository.repo[0].name
  secret_name      = "${upper(var.env)}_AZURE_PUBLISH_PROFILE"
  plaintext_value  = templatefile("${path.module}/publish.xml.tmpl", {
    host = local.app_service_host
    user = local.app_service_user
    password = local.app_service_password
  })
}

