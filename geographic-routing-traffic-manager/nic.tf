resource "azurerm_network_interface" "nic_fr" {
  name                = "nic-fr"
  location            = var.location_fr
  resource_group_name = azurerm_resource_group.rg_fr.name

  ip_configuration {
    name                          = "ipconfig-fr"
    subnet_id                     = azurerm_subnet.subnet_fr.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.server1_ip.id
  }

}

resource "azurerm_network_interface" "nic_us" {
  name                = "nic-us"
  location            = var.location_us
  resource_group_name = azurerm_resource_group.rg_us.name

  ip_configuration {
    name                          = "ipconfig-us"
    subnet_id                     = azurerm_subnet.subnet_us.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.server2_ip.id
  }

}

resource "azurerm_network_interface_security_group_association" "nic_fr_nsg" {
  network_interface_id      = azurerm_network_interface.nic_fr.id
  network_security_group_id = azurerm_network_security_group.nsg_fr.id
}

resource "azurerm_network_interface_security_group_association" "nic_us_nsg" {
  network_interface_id      = azurerm_network_interface.nic_us.id
  network_security_group_id = azurerm_network_security_group.nsg_us.id
}
