output "load_balancer_public_ip" {
  value       = azurerm_public_ip.lb_public_ip.ip_address
  description = "Public IP address of the Load Balancer"
}
