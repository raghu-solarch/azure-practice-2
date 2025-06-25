resource "azurerm_linux_virtual_machine" "dev-ubuntu-vm" {
  name                  = "dev-ubuntu-vm"
  resource_group_name   = azurerm_resource_group.dev-resource-group.name
  location              = azurerm_resource_group.dev-resource-group.location
  size                  = "Standard_B1s"
  admin_username        = "learning"
  network_interface_ids = [azurerm_network_interface.dev-nic.id]

  disable_password_authentication = false
  admin_password                  = "Redhat@12345"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  # Cloud-init script to install Apache and show Hello World
  custom_data = base64encode(<<EOF
#!/bin/bash
apt update -y
apt install apache2 -y
service apache2 restart
echo "Hello world" > /var/www/html/index.html
EOF
  )
}
