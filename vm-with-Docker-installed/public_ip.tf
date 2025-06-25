resource "azurerm_public_ip" "dev_public_ip" {
  name                = "dev_public_ip"
  location            = azurerm_resource_group.dev-resource-group.location
  resource_group_name = azurerm_resource_group.dev-resource-group.name
  allocation_method   = "Static"
}