resource "azurerm_virtual_network" "k8s-virtual-network" {
  name                = var.virtual_network_name
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.k8s-resource-group.location
  resource_group_name = azurerm_resource_group.k8s-resource-group.name
}
