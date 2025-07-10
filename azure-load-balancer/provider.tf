terraform {
  required_providers {
    azurerm = {
      source  = "azurerm"
      version = "4.24.0"
    }
  }
}

provider "azurerm" {
  features {}
  use_cli         = true
  subscription_id = "3cb5b17b-f702-4534-bf9d-f5e83dd19e4c"
}
