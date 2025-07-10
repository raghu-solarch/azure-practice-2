provider "azurerm" {
  features {}
  use_cli         = true
  subscription_id = var.subscription_id
}
