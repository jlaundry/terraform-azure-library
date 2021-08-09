
locals {
  suffix = "${lower(var.env)}-${lower(replace(var.location, " ", ""))}"
}

resource "random_id" "instance_id" {
  byte_length = 4
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-updatecompliance-${local.suffix}"
  location = var.location

  tags = var.tags
}

resource "azurerm_log_analytics_workspace" "log" {
  name                = "log-updatecompliance-${local.suffix}-${random_id.instance_id.hex}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "pergb2018"

  tags = var.tags
}

resource "azurerm_log_analytics_solution" "wufb" {
  solution_name         = "WaaSUpdateInsights"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  workspace_resource_id = azurerm_log_analytics_workspace.log.id
  workspace_name        = azurerm_log_analytics_workspace.log.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/WaaSUpdateInsights"
  }

  tags = var.tags
}
