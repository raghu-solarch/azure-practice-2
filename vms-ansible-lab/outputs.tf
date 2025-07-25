output "server_public_ip" {
  value = azurerm_public_ip.public_ip[0].ip_address
}
output "client1_public_ip" {
  value = azurerm_public_ip.public_ip[1].ip_address
}
output "client2_public_ip" {
  value = azurerm_public_ip.public_ip[2].ip_address
}
output "server_private_ip" {
  value = azurerm_network_interface.nic[0].private_ip_address
}
output "client1_private_ip" {
  value = azurerm_network_interface.nic[1].private_ip_address
}
output "client2_private_ip" {
  value = azurerm_network_interface.nic[2].private_ip_address
}
