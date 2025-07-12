output "vmss_name" {
  value = azurerm_linux_virtual_machine_scale_set.vmss.name
}

output "load_balancer_public_ip" {
  value = azurerm_public_ip.lb_public_ip.ip_address
}

output "user_assigned_identity_id" {
  value = azurerm_user_assigned_identity.vmss_identity.id
}
