# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "vnet-peering-rg"
  location = "France Central"
}
