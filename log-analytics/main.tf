
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.2.0"
    }
  }
}

locals {
  instance_id         = var.instance_id != "" ? var.instance_id : random_id.instance_id[0].hex
  resource_group_name = var.resource_group_name != "" ? var.resource_group_name : azurerm_resource_group.rg[0].name
  suffix              = "${lower(var.env)}-${replace(lower(var.location), " ", "")}"
}

resource "random_id" "instance_id" {
  count    = var.instance_id == "" ? 1 : 0

  byte_length = 4
}

resource "azurerm_resource_group" "rg" {
  count    = var.resource_group_name == "" ? 1 : 0

  name     = "rg-${var.name}-${local.suffix}"
  location = var.location

  tags = var.tags
}

resource "azurerm_log_analytics_workspace" "log" {
  name                = "log-${var.name}-${local.suffix}-${local.instance_id}"
  location            = var.location
  resource_group_name = local.resource_group_name
  sku                 = "PerGB2018"

  tags = var.tags
}
