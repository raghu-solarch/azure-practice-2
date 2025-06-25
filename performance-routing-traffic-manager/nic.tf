resource "azurerm_network_interface" "nic1" {
  name                = "nic1"
  location            = var.location_fr
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.server1_ip.id
  }
}

resource "azurerm_network_interface" "nic2" {
  name                = "nic2"
  location            = var.location_us
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig2"
    subnet_id                     = azurerm_subnet.subnet2.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.server2_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "nic1_nsg" {
  network_interface_id      = azurerm_network_interface.nic1.id
  network_security_group_id = azurerm_network_security_group.nsg_fr.id
}

resource "azurerm_network_interface_security_group_association" "nic2_nsg" {
  network_interface_id      = azurerm_network_interface.nic2.id
  network_security_group_id = azurerm_network_security_group.nsg_us.id
}
