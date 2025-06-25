resource "azurerm_network_interface" "k8s-nic" {
  for_each            = toset(var.vm_names)
  name                = "${var.nic_name}_${each.key}"
  location            = azurerm_resource_group.k8s-resource-group.location
  resource_group_name = azurerm_resource_group.k8s-resource-group.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.k8s-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.k8s_public_ip[each.key].id
  }
}
