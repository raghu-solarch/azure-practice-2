output "vm_names" {
  value = [for vm in azurerm_linux_virtual_machine.main : vm.name]
}
output "public_ips" {
  value = [for pip in azurerm_public_ip.main : pip.ip_address]
}
