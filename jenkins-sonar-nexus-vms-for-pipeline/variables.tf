variable "location" {
  default = "eastus"
}

variable "resource_group_name" {
  default = "prod-demo-rg"
}

variable "admin_username" {
  default = "learning"
}

variable "admin_password" {
  default = "Redhat@12345"
}

variable "vm_size" {
  default = "Standard_D2s_v3"
}

variable "address_space" {
  default = "10.10.0.0/16"
}

variable "subnet_prefix" {
  default = "10.10.1.0/24"
}
