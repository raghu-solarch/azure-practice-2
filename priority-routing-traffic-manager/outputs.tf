# outputs.tf

output "server1_public_ip" {
  description = "Public IP address of server1"
  value       = azurerm_public_ip.server1_ip.ip_address
}

output "server2_public_ip" {
  description = "Public IP address of server2"
  value       = azurerm_public_ip.server2_ip.ip_address
}

output "traffic_manager_fqdn" {
  description = "DNS name of the Traffic Manager profile"
  value       = azurerm_traffic_manager_profile.tm_profile.fqdn
}
