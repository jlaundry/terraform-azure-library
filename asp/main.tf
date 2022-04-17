
locals {
  resource_group_name = var.resource_group_name != "" ? var.resource_group_name : azurerm_resource_group.rg[0].name
  suffix = "${lower(var.env)}-${lower(replace(var.location, " ", ""))}"
}

resource "azurerm_resource_group" "rg" {
  count    = var.resource_group_name == "" ? 1 : 0

  name     = "rg-${var.name}-${local.suffix}"
  location = var.location

  tags = var.tags
}

resource "azurerm_service_plan" "asp" {
  name                = "asp-${var.name}-${local.suffix}"
  location            = var.location
  resource_group_name = local.resource_group_name

  os_type             = var.os_type
  sku_name            = var.sku_name

  tags = var.tags
}
