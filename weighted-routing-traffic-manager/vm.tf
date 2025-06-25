locals {
  script_server1 = <<-EOT
    #!/bin/bash
    apt update -y
    apt install apache2 -y
    service apache2 restart
    echo "server1 france central" > /var/www/html/index.html
  EOT

  script_server2 = <<-EOT
    #!/bin/bash
    apt update -y
    apt install apache2 -y
    service apache2 restart
    echo "server2 east us" > /var/www/html/index.html
  EOT
}

resource "azurerm_linux_virtual_machine" "server1" {
  name                            = "server1"
  resource_group_name             = var.resource_group_name
  location                        = var.location_fr
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.nic1.id]

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

  custom_data = base64encode(local.script_server1)
}

resource "azurerm_linux_virtual_machine" "server2" {
  name                            = "server2"
  resource_group_name             = var.resource_group_name
  location                        = var.location_us
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.nic2.id]

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

  custom_data = base64encode(local.script_server2)
}
