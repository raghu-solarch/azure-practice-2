resource "azurerm_public_ip" "vm_pip" {
  for_each            = local.vm_data
  name                = "pip-${each.value.name}"
  location            = local.location
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}
