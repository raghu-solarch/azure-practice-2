resource "azurerm_resource_group" "dev-resource-group" {
  name     = var.resource_group_name
  location = var.location
}
