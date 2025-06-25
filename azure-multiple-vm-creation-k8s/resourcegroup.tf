resource "azurerm_resource_group" "k8s-resource-group" {
  name     = var.resource_group_name
  location = var.location
}
