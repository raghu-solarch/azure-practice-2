provider "azurerm" {
  features {}
  use_cli = true
  subscription_id = "3cb5b17b-f702-4534-bf9d-f5e83dd19e4c"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = [var.vnet_cidr]
  location            = var.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    Environment = "Production"
  }
}

resource "azurerm_subnet" "public_subnets" {
  count                = length(var.public_subnets)
  name                 = "public-subnet-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.public_subnets[count.index]]
}

resource "azurerm_subnet" "private_subnets" {
  count                = length(var.private_subnets)
  name                 = "private-subnet-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.private_subnets[count.index]]
}
