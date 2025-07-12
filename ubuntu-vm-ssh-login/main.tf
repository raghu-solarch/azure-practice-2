provider "azurerm" {
  features {}
  use_cli         = true
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "dev-resource-group" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "dev-virtual-network" {
  name                = var.virtual_network_name
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.dev-resource-group.location
  resource_group_name = azurerm_resource_group.dev-resource-group.name
}

resource "azurerm_subnet" "dev-subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.dev-resource-group.name
  virtual_network_name = azurerm_virtual_network.dev-virtual-network.name
  address_prefixes     = var.subnet_prefix
}

resource "azurerm_network_security_group" "dev_ntw_security_group" {
  name                = var.nsg_name
  location            = azurerm_resource_group.dev-resource-group.location
  resource_group_name = azurerm_resource_group.dev-resource-group.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "dev-ntw-sec-group_assoc" {
  subnet_id                 = azurerm_subnet.dev-subnet.id
  network_security_group_id = azurerm_network_security_group.dev_ntw_security_group.id
}

resource "azurerm_network_interface" "dev-nic" {
  name                = var.nic_name
  location            = azurerm_resource_group.dev-resource-group.location
  resource_group_name = azurerm_resource_group.dev-resource-group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.dev-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.dev_public_ip.id
  }
}

resource "azurerm_public_ip" "dev_public_ip" {
  name                = var.public_ip_name
  location            = azurerm_resource_group.dev-resource-group.location
  resource_group_name = azurerm_resource_group.dev-resource-group.name
  allocation_method   = "Static"
}

resource "azurerm_linux_virtual_machine" "dev-ubuntu-vm" {
  name                            = var.vm_name
  resource_group_name             = azurerm_resource_group.dev-resource-group.name
  location                        = azurerm_resource_group.dev-resource-group.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  network_interface_ids           = [azurerm_network_interface.dev-nic.id]
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.public_ssh_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.disk_size
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  custom_data = base64encode(<<EOF
#!/bin/bash
apt update -y
apt install apache2 -y
service apache2 restart
echo "Hello world" > /var/www/html/index.html
EOF
  )
}

output "public_ip" {
  value = azurerm_public_ip.dev_public_ip.ip_address
}
