resource "azurerm_network_interface" "dev-nic" {
  name                = "dev-nic"
  location            = azurerm_resource_group.dev-resource-group.location
  resource_group_name = azurerm_resource_group.dev-resource-group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.dev-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.dev_public_ip.id
  }
}