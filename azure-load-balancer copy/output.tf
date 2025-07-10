output "load_balancer_public_ip" {
  value       = azurerm_public_ip.lb_public_ip.ip_address
  description = "Public IP address of the Load Balancer"
}

output "vm_public_ips" {
  value = [for pip in azurerm_public_ip.vm_pip : pip.ip_address]
}
