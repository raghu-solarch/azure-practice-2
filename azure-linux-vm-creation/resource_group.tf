# Create a resource group
resource "azurerm_resource_group" "dev-resource-group" {
  name     = "dev-resource-group"
  location = "France Central"
}
