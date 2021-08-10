
locals {
  ipv6_network  = "${local.ipv6_prefix}::/48"
  ipv6_prefix   = "${substr(random_id.ipv6_ula.hex, 0, 4)}:${substr(random_id.ipv6_ula.hex, 4, 4)}:${substr(random_id.ipv6_ula.hex, 8, 4)}"
  resource_group_name = var.resource_group_name != "" ? var.resource_group_name : azurerm_resource_group.rg[0].name
  suffix       = "${lower(var.env)}-${lower(replace(var.location, " ", ""))}"
}
resource "random_id" "ipv6_ula" {
  byte_length = 5
  prefix      = "fd"
}

resource "azurerm_resource_group" "rg" {
  count    = var.resource_group_name == "" ? 1 : 0

  name     = "rg-vnet-${local.suffix}"
  location = var.location

  tags = var.tags
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.name}-${local.suffix}"
  location            = var.location
  resource_group_name = local.resource_group_name
  address_space       = ["${var.ipv4_prefix}.0.0/16", local.ipv6_network]

  tags = var.tags
}

resource "azurerm_subnet" "subnet" {
  for_each             = var.subnets

  name                 = each.key
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["${var.ipv4_prefix}.${each.value}.0/24", "${local.ipv6_prefix}:${each.value}::/64"]
}
