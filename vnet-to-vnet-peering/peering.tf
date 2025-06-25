# 5. Add peering on virtual network vnet1. peering link name = vnet1-to-vnet1-peering, virtual network = vnet2, enable allow vnet2 to access vnet1 and enable allow vnet2 to receive forwarded traffic from vnet1, under the local virtual network summary, add peering link name as vnet1-to-vnet2-peering and enable vnet1 to access vnet2 and enable allow vnet1 to receive forwarded traffic from vnet2,. ensure peering status is fully in sync and connected.

# Peering from vnet1 to vnet2
resource "azurerm_virtual_network_peering" "vnet1_to_vnet2_peering" {
  name                         = "vnet1-to-vnet2-peering"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.vnet1.name
  remote_virtual_network_id    = azurerm_virtual_network.vnet2.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false # Set to true if you have a VPN Gateway in vnet2 and want vnet1 to use it
  use_remote_gateways          = false # Set to true if you want vnet1 to use a VPN Gateway in vnet2
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
