# 5. Add peering on virtual network vnet1 to vnet2
resource "azurerm_virtual_network_peering" "vnet1_to_vnet2_peering" {
  name                         = "${var.vnet1_name}-to-${var.vnet2_name}-peering"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.vnet1.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet2.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# Peering from vnet2 to vnet1 (the reciprocal peering)
resource "azurerm_virtual_network_peering" "vnet2_to_vnet1_peering" {
  name                         = "vnet2-to-vnet1-peering"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.vnet2.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet1.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}
