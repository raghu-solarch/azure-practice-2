# 3. Create a virtual network with name vnet2
resource "azurerm_virtual_network" "vnet2" {
  name                = var.vnet2_name
  location            = var.vnet2_location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet2_address_space]

  encryption {
    enforcement = "AllowUnencrypted"
  }
}

# Create a subnet for vnet2
resource "azurerm_subnet" "vnet2_subnet" {
  name                 = var.vnet2_subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefixes     = [var.vnet2_subnet_address_prefix]
}

# Create a Network Security Group for Server2
resource "azurerm_network_security_group" "nsg_server2" {
  name                = "nsg-server2"
  location            = var.vnet2_location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 100
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
    priority                   = 101
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
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create a Public IP for Server2
resource "azurerm_public_ip" "server2_public_ip" {
  name                = var.server2_public_ip_name
  location            = var.vnet2_location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create a Network Interface for Server2
resource "azurerm_network_interface" "server2_nic" {
  name                = var.server2_nic_name
  location            = var.vnet2_location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vnet2_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.server2_public_ip.id
  }
}

# Associate NSG with Server2 NIC
resource "azurerm_network_interface_security_group_association" "server2_nsg_association" {
  network_interface_id      = azurerm_network_interface.server2_nic.id
  network_security_group_id = azurerm_network_security_group.nsg_server2.id
}
