resource "azurerm_network_security_group" "nsg_fr" {
  name                = "nsg-fr"
  location            = var.location_fr
  resource_group_name = azurerm_resource_group.rg_fr.name

  security_rule {
    name                       = "allow_http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}

resource "azurerm_network_security_group" "nsg_us" {
  name                = "nsg-us"
  location            = var.location_us
  resource_group_name = azurerm_resource_group.rg_us.name

  security_rule {
    name                       = "allow_http"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

}
