# Create a resource group
resource "azurerm_resource_group" "dev-resource-group" {
  name     = "edev-resource-group"
  location = "France Central"
}