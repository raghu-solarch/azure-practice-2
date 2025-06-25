resource "azurerm_subnet" "k8s-subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.k8s-resource-group.name
  virtual_network_name = azurerm_virtual_network.k8s-virtual-network.name
  address_prefixes     = var.subnet_prefix
}
