output "public_ips" {
  value = { for name, pip in azurerm_public_ip.public_ip : name => pip.ip_address }
}
