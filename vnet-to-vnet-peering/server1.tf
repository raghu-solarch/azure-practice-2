# 2. Create a virtual machine which with name server1 and region = France central, no redundancy required, with image ubuntu server 24.04 lts x64 gen2, with standard_b1s size, authentication type as password, username = learning, password = Redhat@12345, enable all ports like ssh, http and https, select standard hdd as os disk type, select vnet1 virtual network.
resource "azurerm_linux_virtual_machine" "server1" {
  name                            = "server1"
  location                        = "France Central"
  resource_group_name             = azurerm_resource_group.rg.name
  size                            = "Standard_B1s"
  admin_username                  = "learning"
  admin_password                  = "Redhat@12345"
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.server1_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "server1-osdisk"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}
