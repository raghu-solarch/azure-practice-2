resource "azurerm_public_ip" "public_ip" {
  for_each            = toset(var.vm_names)
  name                = "${var.public_ip_name}_${each.key}"
  location            = azurerm_resource_group.resource-group.location
  resource_group_name = azurerm_resource_group.resource-group.name
  allocation_method   = "Static"
}
