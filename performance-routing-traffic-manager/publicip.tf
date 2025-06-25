resource "azurerm_public_ip" "server1_ip" {
  name                = "server1-public-ip"
  location            = var.location_fr
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  domain_name_label   = var.domain_label_server1
}

resource "azurerm_public_ip" "server2_ip" {
  name                = "server2-public-ip"
  location            = var.location_us
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  domain_name_label   = var.domain_label_server2
}
