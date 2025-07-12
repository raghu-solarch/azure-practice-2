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

resource "azurerm_public_ip" "dev_public_ip" {
  count               = length(var.zones)
  name                = "my_public_ip-${var.zones[count.index]}"
  location            = azurerm_resource_group.dev-resource-group.location
  resource_group_name = azurerm_resource_group.dev-resource-group.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "dev-nic" {
  count               = length(var.zones)
  name                = "my-nic-${var.zones[count.index]}"
  location            = azurerm_resource_group.dev-resource-group.location
  resource_group_name = azurerm_resource_group.dev-resource-group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.dev-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.dev_public_ip[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "dev-ubuntu-vm" {
  count                           = length(var.zones)
  name                            = "${var.vm_name_prefix}-${var.zones[count.index]}"
  resource_group_name             = azurerm_resource_group.dev-resource-group.name
  location                        = azurerm_resource_group.dev-resource-group.location
  size                            = var.vm_size
  admin_username                  = var.admin_username
  admin_password                  = var.admin_password
  network_interface_ids           = [azurerm_network_interface.dev-nic[count.index].id]
  disable_password_authentication = false
  zone                            = var.zones[count.index]

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
echo "Hello from VM in AZ $${ZONE}" > /var/www/html/index.html
EOF
  )
}

output "public_ips" {
  value = azurerm_public_ip.dev_public_ip[*].ip_address
}
