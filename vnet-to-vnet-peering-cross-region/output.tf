
output "server1_public_ip" {
  description = "The public IP address of server1."
  value       = azurerm_public_ip.server1_public_ip.ip_address
}

output "server2_public_ip" {
  description = "The public IP address of server2."
  value       = azurerm_public_ip.server2_public_ip.ip_address
}


