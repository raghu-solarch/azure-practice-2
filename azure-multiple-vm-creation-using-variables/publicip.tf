resource "azurerm_public_ip" "public_ip" {
  for_each            = toset(var.vm_names)
  name                = "${each.key}-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}
