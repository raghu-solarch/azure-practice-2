output "public_ip" {
  value = azurerm_public_ip.docker_public_ip.ip_address
}
