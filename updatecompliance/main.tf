
locals {
  resource_group_name = var.resource_group_name != "" ? var.resource_group_name : azurerm_resource_group.rg[0].name
  suffix = "${lower(var.env)}-${replace(lower(var.location), " ", "")}"
}

resource "azurerm_resource_group" "rg" {
  count    = var.resource_group_name == "" ? 1 : 0

  name     = "rg-${var.name}-${local.suffix}"
  location = var.location

  tags = var.tags
}

module "log" {
  source              = "../log-analytics"

  env                 = var.env
  location            = var.location
  name                = var.name
  resource_group_name = local.resource_group_name

  tags = var.tags
}

resource "azurerm_log_analytics_solution" "wufb" {
  solution_name         = "WaaSUpdateInsights"
  location              = var.location
  resource_group_name   = module.log.resource_group_name
  workspace_resource_id = module.log.id
  workspace_name        = module.log.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/WaaSUpdateInsights"
  }

  tags = var.tags
}
