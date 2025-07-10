# Create a resource group
resource "azurerm_resource_group" "docker-rg" {
  name     = "docker-rg"
  location = "France Central"
}
