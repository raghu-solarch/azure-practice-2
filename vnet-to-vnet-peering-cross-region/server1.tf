# 2. Create a virtual machine server1
resource "azurerm_linux_virtual_machine" "server1" {
  name                            = var.server1_name
  location                        = var.vnet1_location
  resource_group_name             = azurerm_resource_group.rg.name
  size                            = var.vm_size
  admin_username                  = var.vm_admin_username
  admin_password                  = var.vm_admin_password
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.server1_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    name                 = "${var.server1_name}-osdisk"
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.vm_image_publisher
    offer     = var.vm_image_offer
    sku       = var.vm_image_sku
    version   = var.vm_image_version
  }
}
