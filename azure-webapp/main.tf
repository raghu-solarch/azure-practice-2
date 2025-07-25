provider "azurerm" {
  features {}
  use_cli         = true
  subscription_id = "3cb5b17b-f702-4534-bf9d-f5e83dd19e4c"
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-demo-flask"
  location = "West Europe"
}

resource "azurerm_service_plan" "asp" {
  name                = "demo-flask-asp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "webapp" {
  name                = "cbc-webapp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    always_on = false
  }
}
