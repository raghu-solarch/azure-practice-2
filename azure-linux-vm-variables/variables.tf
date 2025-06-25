variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = "3cb5b17b-f702-4534-bf9d-f5e83dd19e4c"
}

variable "location" {
  description = "Azure Region"
  type        = string
  default     = "France Central"
}

variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
  default     = "learning"
}

variable "virtual_network_name" {
  description = "Virtual Network Name"
  type        = string
  default     = "vnet1"
}

variable "vnet_address_space" {
  description = "Virtual Network address space"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_name" {
  description = "Subnet Name"
  type        = string
  default     = "vnet1-subnet"
}

variable "subnet_prefix" {
  description = "Subnet address prefix"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "nsg_name" {
  description = "Network Security Group Name"
  type        = string
  default     = "my-nsg"
}

variable "nic_name" {
  description = "NIC Name"
  type        = string
  default     = "my-nic"
}

variable "public_ip_name" {
  description = "Public IP Name"
  type        = string
  default     = "my_public_ip"
}

variable "vm_name" {
  description = "VM Name"
  type        = string
  default     = "my-ubuntu-vm"
}

variable "vm_size" {
  description = "VM Size"
  type        = string
  default     = "Standard_B1s"
}

variable "admin_username" {
  description = "Admin Username"
  type        = string
  default     = "learning"
}

variable "admin_password" {
  description = "Admin Password"
  type        = string
  sensitive   = true
  default     = "Redhat@12345"
}

variable "disk_size" {
  description = "OS Disk Size (GB)"
  type        = number
  default     = 30
}
