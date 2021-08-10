
resource "azurerm_public_ip" "ip4" {
  name                    = "${var.name}-ip4"
  location                = var.location
  resource_group_name     = var.resource_group_name
  
  # IPv6 not supported on Basic SKU, cannot mix and match
  allocation_method       = "Static"
  sku                     = "Standard"
  
  idle_timeout_in_minutes = 30

  ip_version = "IPv4"

  tags = var.tags
}

resource "azurerm_public_ip" "ip6" {
  name                    = "${var.name}-ip6"
  location                = var.location
  resource_group_name     = var.resource_group_name
  
  # IPv6 not supported on Basic SKU, Standard SKU is Statically allocated
  allocation_method       = "Static"
  sku                     = "Standard"

  idle_timeout_in_minutes = 30

  ip_version = "IPv6"

  tags = var.tags
}

resource "azurerm_network_interface" "nic0" {
  name                = "${var.name}-nic0"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    primary                       = true
    name                          = "internal4"
    subnet_id                     = var.subnet_id
    private_ip_address_version    = "IPv4"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip4.id
  }

  ip_configuration {
    name                          = "internal6"
    subnet_id                     = var.subnet_id
    private_ip_address_version    = "IPv6"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ip6.id
  }

  tags = var.tags
}
