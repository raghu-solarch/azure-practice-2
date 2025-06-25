# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  use_cli         = var.use_cli_auth
  subscription_id = "3cb5b17b-f702-4534-bf9d-f5e83dd19e4c"
}
