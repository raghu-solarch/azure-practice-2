variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = "3cb5b17b-f702-4534-bf9d-f5e83dd19e4c"
}
variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
  default     = "learning"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "France Central"
}

variable "vnet_name" {
  description = "VNet name"
  type        = string
  default     = "vnet1"
}

variable "vnet_address_space" {
  description = "VNet address space"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_name" {
  description = "Subnet name"
  type        = string
  default     = "vnet1-subnet"
}

variable "subnet_prefix" {
  description = "Subnet address prefix"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "nsg_name" {
  description = "Network Security Group name"
  type        = string
  default     = "my-nsg"
}

variable "admin_username" {
  description = "VM admin username"
  type        = string
  default     = "learning"
}

variable "admin_password" {
  description = "VM admin password"
  type        = string
  sensitive   = true
  default     = "Redhat@12345"
}

variable "vm_size" {
  description = "VM size"
  type        = string
  default     = "Standard_B1s"
}

variable "os_disk_size" {
  description = "OS disk size in GB"
  type        = number
  default     = 30
}

variable "vm_names" {
  description = "List of VM names to create"
  type        = list(string)
  default     = ["server1", "server2"]
}
