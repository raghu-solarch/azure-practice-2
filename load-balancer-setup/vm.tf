locals {
  resource_group_name = "RaghuSolArch"
  location            = "francecentral"

  vm_data = {
    server1 = {
      name = "vm1"
      custom_data = base64encode(<<EOF
#!/bin/bash
apt update
apt install apache2 -y
systemctl restart apache2
echo "server1" > /var/www/html/index.html
EOF
      )
    }
    server2 = {
      name = "vm2"
      custom_data = base64encode(<<EOF
#!/bin/bash
apt update 
apt install apache2 -y
systemctl restart apache2
echo "server2" > /var/www/html/index.html
EOF
      )
    }
  }
}


resource "azurerm_linux_virtual_machine" "vm" {
  for_each                        = local.vm_data
  name                            = each.value.name
  location                        = local.location
  resource_group_name             = local.resource_group_name
  network_interface_ids           = [azurerm_network_interface.nic[each.key].id]
  size                            = "Standard_B1s"
  admin_username                  = "learning"
  admin_password                  = "Redhat@12345"
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "osdisk-${each.value.name}"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = each.value.custom_data
}


