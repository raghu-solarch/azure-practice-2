resource "azurerm_subnet" "docker-subnet" {
  name                 = "docker-subnet"
  resource_group_name  = azurerm_resource_group.docker-rg.name
  virtual_network_name = azurerm_virtual_network.docker-vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Associate NSG to subnet

resource "azurerm_subnet_network_security_group_association" "docker-ntw-sec-group_assoc" {
  subnet_id                 = azurerm_subnet.docker-subnet.id
  network_security_group_id = azurerm_network_security_group.docker-ntw-security-group.id
}
