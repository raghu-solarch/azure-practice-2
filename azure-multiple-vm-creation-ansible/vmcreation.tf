resource "azurerm_linux_virtual_machine" "ubuntu-vm" {
  for_each              = toset(var.vm_names)
  name                  = each.key
  resource_group_name   = azurerm_resource_group.resource-group.name
  location              = azurerm_resource_group.resource-group.location
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic[each.key].id]

  disable_password_authentication = false
  admin_password                  = var.admin_password

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.disk_size
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
  # source_image_reference {
  #   publisher = "Canonical"
  #   offer     = "0001-com-ubuntu-server-jammy"
  #   sku       = "22_04-lts"
  #   version   = "latest"
  # }

}


