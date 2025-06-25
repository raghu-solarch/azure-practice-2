resource "azurerm_subnet" "dev-subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.dev-resource-group.name
  virtual_network_name = azurerm_virtual_network.dev-virtual-network.name
  address_prefixes     = var.subnet_prefix
}
