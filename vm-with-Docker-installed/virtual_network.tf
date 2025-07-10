# Create a virtual network
resource "azurerm_virtual_network" "docker-vnet" {
  name                = "docker-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.docker-rg.location
  resource_group_name = azurerm_resource_group.docker-rg.name
}
