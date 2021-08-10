
module "log" {
  source              = "../log-analytics"

  env                 = var.env
  location            = var.location
  name                = "updatecompliance"
  resource_group_name = var.resource_group_name

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
