variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = "3cb5b17b-f702-4534-bf9d-f5e83dd19e4c"
}

variable "resource_group_name" {
  default = "vmss-prod-rg"
}

variable "location" {
  default = "eastus2"
}

variable "vnet_address_space" {
  default = ["10.11.0.0/16"]
}

variable "subnet_address_prefix" {
  default = ["10.11.1.0/24"]
}

variable "nsg_allowed_ssh_cidr" {
  description = "Allowed CIDR for SSH (your public IP or range)"
  default     = "YOUR_PUBLIC_IP/32"
}

variable "vmss_name" {
  default = "prod-vmss"
}

variable "admin_username" {
  default = "azureuser"
}

variable "admin_password" {
  description = "Password for admin user"
  default     = "Redhat@12345"
}

variable "instance_count" {
  default = 2
}

variable "vm_size" {
  default = "Standard_B1s"
}

variable "zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = ["1", "2"]
}
