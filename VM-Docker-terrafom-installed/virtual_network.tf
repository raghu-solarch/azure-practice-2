# Create a virtual network
resource "azurerm_virtual_network" "dev-virtual-network" {
  name                = "dev-virtual-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.dev-resource-group.location
  resource_group_name = azurerm_resource_group.dev-resource-group.name
}