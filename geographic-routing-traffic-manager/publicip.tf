resource "azurerm_public_ip" "server1_ip" {
  name                = "server1-public-ip"
  location            = var.location_fr
  resource_group_name = azurerm_resource_group.rg_fr.name
  allocation_method   = "Static"
  domain_name_label   = "server1-fr-demo" # must be unique in Azure

}

resource "azurerm_public_ip" "server2_ip" {
  name                = "server2-public-ip"
  location            = var.location_us
  resource_group_name = azurerm_resource_group.rg_us.name
  allocation_method   = "Static"
  domain_name_label   = "server2-us-demo" # must be unique in Azure

}
