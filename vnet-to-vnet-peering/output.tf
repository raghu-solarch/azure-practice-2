# Output the public IP addresses of the VMs
output "server1_public_ip" {
  value = azurerm_public_ip.server1_public_ip.ip_address
}

output "server2_public_ip" {
  value = azurerm_public_ip.server2_public_ip.ip_address
}
