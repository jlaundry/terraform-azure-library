
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
  app_service_host     = azurerm_function_app.func.name
  app_service_user     = azurerm_function_app.func.site_credential[0].username
  app_service_password = azurerm_function_app.func.site_credential[0].password

  instance_name        = "${lower(var.name)}-${local.suffix}-${random_id.instance_id.hex}"
  resource_group_name  = var.resource_group_name != "" ? var.resource_group_name : azurerm_resource_group.rg[0].name
  suffix               = "${lower(var.env)}-${lower(replace(var.location, " ", ""))}"
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

resource "azurerm_app_service_plan" "asp" {
  name                = "asp-${local.instance_name}"
  location            = var.location
  resource_group_name = local.resource_group_name
  kind                = "FunctionApp"
  reserved            = true

  sku {
    tier = "Dynamic"
    size = "Y1"
  }

  tags = var.tags
}

resource "azurerm_function_app" "func" {
  name                = "func-${local.instance_name}"
  location            = var.location
  resource_group_name = local.resource_group_name
  app_service_plan_id = azurerm_app_service_plan.asp.id

  storage_account_name       = azurerm_storage_account.app.name
  storage_account_access_key = azurerm_storage_account.app.primary_access_key

  version                    = "~3"
  os_type                    = var.os_type
  https_only                 = true

  identity {
    type = "SystemAssigned"
  }

  app_settings = merge(
    {
      FUNCTIONS_WORKER_RUNTIME = "python"
      APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.appi.instrumentation_key
      APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.appi.connection_string
    },
    var.app_settings,
  )

  site_config {
    linux_fx_version  = var.linux_fx_version
    ftps_state        = "Disabled"
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

