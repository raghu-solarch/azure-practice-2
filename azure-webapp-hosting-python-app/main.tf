terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.87.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
  subscription_id            = "3cb5b17b-f702-4534-bf9d-f5e83dd19e4c"
}

resource "azurerm_resource_group" "rg" {
  name     = "my-webapp-rg"
  location = "France Central"
}

resource "azurerm_service_plan" "linuxplan" {
  name                   = "mycbcwebapp1-project1"
  location               = azurerm_resource_group.rg.location
  resource_group_name    = azurerm_resource_group.rg.name
  os_type                = "Linux"
  sku_name               = "P1v3"
  zone_balancing_enabled = false
}

resource "azurerm_linux_web_app" "webapp" {
  name                = "mycbcwebapp1rg-project1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.linuxplan.id
  https_only          = true

  site_config {
    application_stack {
      python_version = "3.10"
    }
  }
}

resource "azurerm_app_service_source_control" "github" {
  app_id                 = azurerm_linux_web_app.webapp.id
  repo_url               = "https://github.com/raghu-solarch/app-service-web-python-get-started"
  branch                 = "master"
  use_manual_integration = false
  use_mercurial          = false

}

output "webapp_url" {
  description = "The default URL for your Azure Web App"
  value       = "https://${azurerm_linux_web_app.webapp.default_hostname}"
}
