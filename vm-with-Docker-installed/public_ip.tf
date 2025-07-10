resource "azurerm_public_ip" "docker_public_ip" {
  name                = "docker_public_ip"
  location            = azurerm_resource_group.docker-rg.location
  resource_group_name = azurerm_resource_group.docker-rg.name
  allocation_method   = "Static"
}
