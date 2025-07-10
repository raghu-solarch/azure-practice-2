resource "azurerm_virtual_network" "vnet_fr" {
  name                = "vnet-fr"
  address_space       = ["10.0.0.0/16"]
  location            = var.location_fr
  resource_group_name = azurerm_resource_group.rg_fr.name

}

resource "azurerm_virtual_network" "vnet_us" {
  name                = "vnet-us"
  address_space       = ["10.1.0.0/16"]
  location            = var.location_us
  resource_group_name = azurerm_resource_group.rg_us.name

}

resource "azurerm_subnet" "subnet_fr" {
  name                 = "subnet-fr"
  resource_group_name  = azurerm_resource_group.rg_fr.name
  virtual_network_name = azurerm_virtual_network.vnet_fr.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "subnet_us" {
  name                 = "subnet-us"
  resource_group_name  = azurerm_resource_group.rg_us.name
  virtual_network_name = azurerm_virtual_network.vnet_us.name
  address_prefixes     = ["10.1.1.0/24"]
}
