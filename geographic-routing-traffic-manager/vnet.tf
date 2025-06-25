resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet1"
  address_space       = ["10.0.0.0/16"]
  location            = var.location_fr
  resource_group_name = var.resource_group_name
}

resource "azurerm_virtual_network" "vnet2" {
  name                = "vnet2"
  address_space       = ["10.1.0.0/16"]
  location            = var.location_us
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet1.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet2.name
  address_prefixes     = ["10.1.1.0/24"]
}
