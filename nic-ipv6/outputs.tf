
output "id" {
    value = azurerm_network_interface.nic0.id
}

output "private_ip4" {
    value = azurerm_network_interface.nic0.ip_configuration[index(azurerm_network_interface.nic0.ip_configuration.*.name, "internal4")].private_ip_address
}

output "public_ip4" {
    value = azurerm_public_ip.ip4.ip_address
}

output "private_ip6" {
    value = azurerm_network_interface.nic0.ip_configuration[index(azurerm_network_interface.nic0.ip_configuration.*.name, "internal6")].private_ip_address
}

output "public_ip6" {
    value = azurerm_public_ip.ip6.ip_address
}
