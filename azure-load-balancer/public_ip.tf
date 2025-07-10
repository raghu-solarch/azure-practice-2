resource "azurerm_public_ip" "vm_pip" {
  for_each            = local.vm_data
  name                = "pip-${each.value.name}"
  location            = azurerm_resource_group.RaghuSolArch.location
  resource_group_name = azurerm_resource_group.RaghuSolArch.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
