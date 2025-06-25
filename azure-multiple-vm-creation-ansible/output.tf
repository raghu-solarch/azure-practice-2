output "vm_public_ips" {
  value = {
    for vm in azurerm_linux_virtual_machine.ubuntu-vm :
    vm.name => azurerm_public_ip.public_ip[vm.name].ip_address
  }
}
