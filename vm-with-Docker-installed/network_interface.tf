resource "azurerm_network_interface" "docker-nic" {
  name                = "docker-nic"
  location            = azurerm_resource_group.docker-rg.location
  resource_group_name = azurerm_resource_group.docker-rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.docker-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.docker_public_ip.id
  }
}
