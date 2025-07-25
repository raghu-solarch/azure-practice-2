resource "azurerm_linux_virtual_machine" "docker" {
  name                  = "docker"
  resource_group_name   = azurerm_resource_group.docker-rg.name
  location              = azurerm_resource_group.docker-rg.location
  size                  = "Standard_B2s"
  admin_username        = "learning"
  network_interface_ids = [azurerm_network_interface.docker-nic.id]

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


  custom_data = base64encode(<<EOF
#!/bin/bash
sudo apt-get update
sudo apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
   
sudo apt-get update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io
sudo systemctl start docker
sudo systemctl enable docker
sudo gpasswd -a learning docker
echo "DOCKER INSTALLATION COMPLETE" | tee /var/log/docker_install_status.log
sudo reboot
EOF
  )
}
