
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.2.0"
    }
  }
}

locals {
  instance_id         = random_id.instance_id.hex
  instance_name        = "${lower(var.name)}-${local.suffix}-${random_id.instance_id.hex}"
  resource_group_name = var.resource_group_name != "" ? var.resource_group_name : azurerm_resource_group.rg[0].name
  suffix              = "${lower(var.env)}-${replace(lower(var.location), " ", "")}"
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

resource "azurerm_log_analytics_workspace" "log" {
  name                = "log-${local.instance_name}"
  location            = var.location
  resource_group_name = local.resource_group_name
  sku                 = "PerGB2018"

  retention_in_days   = var.log_retention

  tags = var.tags
}

resource "azurerm_management_lock" "lock" {
  name       = "lock"
  scope      = azurerm_log_analytics_workspace.log.id
  lock_level = "CanNotDelete"
}

resource "azurerm_log_analytics_solution" "securityinsights" {
  solution_name         = "SecurityInsights"
  location              = var.location
  resource_group_name   = local.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.log.id
  workspace_name        = azurerm_log_analytics_workspace.log.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SecurityInsights"
  }

  tags = var.tags
}

resource "azurerm_sentinel_data_connector_azure_active_directory" "aad" {
  count    = var.enable_aad_connector ? 1 : 0

  name                       = "aad"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log.id
} # TODO manual: enable Create Incidents

resource "azurerm_sentinel_data_connector_azure_security_center" "asc" {
  count    = var.enable_asc_connector ? 1 : 0

  name                       = "asc"
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log.id
} # TODO manual: enable Create Incidents

data "azuread_client_config" "current" {
}

resource "azuread_application" "tiapp" {
  display_name               = "Sentinel ${local.instance_id} - Threat Indicators API"

  owners = [
    data.azuread_client_config.current.object_id,
  ]

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"  # User.Read
      type = "Scope"
    }

    resource_access {
      id   = "21792b6c-c986-4ffc-85de-df9da54b52fa"  # ThreatIndicators.ReadWrite.OwnedBy
      type = "Role"
    }
  }
}
