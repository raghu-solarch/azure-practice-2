output "public_ips" {
  description = "Public IP addresses of Jenkins, Sonar, and Nexus VMs"
  value = {
    for k, vm in azurerm_public_ip.vm : k => vm.ip_address
  }
}
