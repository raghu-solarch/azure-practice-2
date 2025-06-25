output "vm_public_ips" {
  value = {
    for vm in azurerm_linux_virtual_machine.k8s-ubuntu-vm :
    vm.name => azurerm_public_ip.k8s_public_ip[vm.name].ip_address
  }
}
