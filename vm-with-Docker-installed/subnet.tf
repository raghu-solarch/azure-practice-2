resource "azurerm_subnet" "dev-subnet" {
  name                 = "dev-subnet"
  resource_group_name  = azurerm_resource_group.dev-resource-group.name
  virtual_network_name = azurerm_virtual_network.dev-virtual-network.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Associate NSG to subnet

resource "azurerm_subnet_network_security_group_association" "dev-ntw-sec-group_assoc" {
  subnet_id                 = azurerm_subnet.dev-subnet.id
  network_security_group_id = azurerm_network_security_group.dev_ntw_security_group.id
}