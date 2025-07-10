resource "azurerm_resource_group" "rg_fr" {
  name     = var.resource_group_name_fr
  location = var.location_fr

}

resource "azurerm_resource_group" "rg_us" {
  name     = var.resource_group_name_us
  location = var.location_us

}
