# 1. Create a virtual network with name vnet1 at France central region with address space as 10.1.0.0/16.
resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet1"
  location            = "France Central"
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.1.0.0/16"]

  encryption {
    enforcement = "AllowUnencrypted"
  }
}

# Create a subnet for vnet1
resource "azurerm_subnet" "vnet1_subnet" {
  name                 = "default"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.1.1.0/24"]
}

# Create a Network Security Group for Server1
resource "azurerm_network_security_group" "nsg_server1" {
  name                = "nsg-server1"
  location            = "France Central"
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

# Create a Public IP for Server1
resource "azurerm_public_ip" "server1_public_ip" {
  name                = "server1-public-ip"
  location            = "France Central"
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard" # Added SKU as Standard
}

# Create a Network Interface for Server1
resource "azurerm_network_interface" "server1_nic" {
  name                = "server1-nic"
  location            = "France Central"
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vnet1_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.server1_public_ip.id
  }
}

# Associate NSG with Server1 NIC
resource "azurerm_network_interface_security_group_association" "server1_nsg_association" {
  network_interface_id      = azurerm_network_interface.server1_nic.id
  network_security_group_id = azurerm_network_security_group.nsg_server1.id
}
