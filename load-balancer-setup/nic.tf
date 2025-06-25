resource "azurerm_network_interface" "nic" {
  for_each            = local.vm_data
  name                = "nic-${each.value.name}"
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "ipconfig-${each.value.name}"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_pip[each.key].id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  for_each                  = azurerm_network_interface.nic
  network_interface_id      = azurerm_network_interface.nic[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface_backend_address_pool_association" "bepool_assoc" {
  for_each                = azurerm_network_interface.nic
  network_interface_id    = azurerm_network_interface.nic[each.key].id
  ip_configuration_name   = "ipconfig-${local.vm_data[each.key].name}"
  backend_address_pool_id = azurerm_lb_backend_address_pool.bpepool.id
}
