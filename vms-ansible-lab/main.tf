resource "azurerm_resource_group" "ansible_rg" {
  name     = "ansible-lab-rg"
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "ansible-lab-vnet"
  address_space       = ["10.1.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.ansible_rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "ansible-lab-subnet"
  resource_group_name  = azurerm_resource_group.ansible_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "ansible-lab-nsg"
  location            = var.location
  resource_group_name = azurerm_resource_group.ansible_rg.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_public_ip" "public_ip" {
  count               = 3
  name                = "ansible-${local.servers[count.index].name}-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.ansible_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "nic" {
  count               = 3
  name                = "ansible-${local.servers[count.index].name}-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.ansible_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip[count.index].id
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_association" {
  count                     = 3
  network_interface_id      = azurerm_network_interface.nic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_linux_virtual_machine" "vm" {
  count                           = 3
  name                            = "ansible-${local.servers[count.index].name}"
  resource_group_name             = azurerm_resource_group.ansible_rg.name
  location                        = var.location
  size                            = "Standard_B1s"
  admin_username                  = "learning"
  admin_password                  = "Redhat@12345"
  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.nic[count.index].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "ansible${local.servers[count.index].name}osdisk"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  depends_on = [azurerm_network_interface_security_group_association.nsg_association]

  # Initial setup: install packages, create ansible user, enable sudo, fix SSH, write /etc/hosts
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y sshpass tree rpm vim",
      "${count.index == 0 ? "sudo apt-get install -y software-properties-common && sudo add-apt-repository --yes --update ppa:ansible/ansible && sudo apt-get install -y ansible" : "echo skip ansible"}",
      # Create ansible user, set password, and give passwordless sudo
      "sudo useradd -m -s /bin/bash ansible || true",
      "echo 'ansible:12345' | sudo chpasswd",
      "echo 'ansible ALL=(ALL:ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/ansible",
      # Enable password authentication for SSH
      "sudo sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config",
      "sudo sed -i 's/^#*KbdInteractiveAuthentication.*/KbdInteractiveAuthentication yes/' /etc/ssh/sshd_config",
      "sudo systemctl restart sshd || sudo service ssh restart",
      # Write /etc/hosts with all nodes' private IPs and names
      "sudo bash -c 'cat <<EOF > /etc/hosts\n127.0.0.1 localhost\n${join("\n", formatlist("%s %s", azurerm_network_interface.nic[*].private_ip_address, local.servers[*].name))}\nEOF'"
    ]
    connection {
      type     = "ssh"
      user     = "learning"
      password = "Redhat@12345"
      host     = azurerm_public_ip.public_ip[count.index].ip_address
      timeout  = "3m"
    }
  }

  # On master only: as ansible user, generate ssh key and copy to clients
  provisioner "remote-exec" {
    when = create
    inline = [
      count.index == 0 ? <<-EOC
        sudo -H -u ansible bash -c '
          if [ ! -f ~/.ssh/id_rsa ]; then
            ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa -q
          fi
          for host in client1 client2; do
            sshpass -p 12345 ssh-copy-id -o StrictHostKeyChecking=no ansible@$host || true
          done
        '
      EOC
      : "echo skip master setup"
    ]
    connection {
      type     = "ssh"
      user     = "learning"
      password = "Redhat@12345"
      host     = azurerm_public_ip.public_ip[count.index].ip_address
      timeout  = "3m"
    }
  }
}
