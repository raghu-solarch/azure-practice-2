locals {
  script_fr = <<-EOT
    #!/bin/bash
    apt update -y
    apt install apache2 -y
    systemctl restart apache2
    echo "server1 france central" > /var/www/html/index.html
  EOT

  script_us = <<-EOT
    #!/bin/bash
    apt update -y
    apt install apache2 -y
    systemctl restart apache2
    echo "server2 east us" > /var/www/html/index.html
  EOT
}

resource "azurerm_linux_virtual_machine" "server1" {
  name                            = "server1-fr"
  resource_group_name             = azurerm_resource_group.rg_fr.name
  location                        = var.location_fr
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.nic_fr.id]

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

  custom_data = base64encode(local.script_fr)
}

resource "azurerm_linux_virtual_machine" "server2" {
  name                            = "server2-us"
  resource_group_name             = azurerm_resource_group.rg_us.name
  location                        = var.location_us
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  disable_password_authentication = false
  network_interface_ids           = [azurerm_network_interface.nic_us.id]

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

  custom_data = base64encode(local.script_us)

}
