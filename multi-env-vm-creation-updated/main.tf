provider "azurerm" {
  features {}
  use_cli         = true
  subscription_id = "3cb5b17b-f702-4534-bf9d-f5e83dd19e4c"
}

module "azure_vm" {
  source          = "./modules/azure-vm"
  env_name        = var.env_name
  vnet_cidr       = var.vnet_cidr
  resource_prefix = var.resource_prefix
  project_name    = var.project_name
  location        = var.location
  admin_username  = var.admin_username
  admin_password  = var.admin_password
  vm_numbers      = var.vm_numbers
}

