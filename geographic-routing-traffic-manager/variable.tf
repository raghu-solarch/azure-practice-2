variable "resource_group_name_fr" {
  description = "Name of the resource group for France Central"
  type        = string
  default     = "learning-fr"
}

variable "resource_group_name_us" {
  description = "Name of the resource group for East US"
  type        = string
  default     = "learning-us"
}

variable "location_fr" {
  description = "Location for France Central resources"
  type        = string
  default     = "France Central"
}

variable "location_us" {
  description = "Location for East US resources"
  type        = string
  default     = "East US"
}

variable "admin_username" {
  description = "Admin username for the virtual machines"
  type        = string
  default     = "learning"
}

variable "admin_password" {
  description = "Admin password for the virtual machines"
  type        = string
  default     = "Redhat@12345" # Use any strong password you like
  sensitive   = true
}


variable "traffic_manager_name" {
  description = "Name of the Traffic Manager profile"
  type        = string
  default     = "geographictrafficmanager123"
}

variable "vm_size" {
  description = "Size of the virtual machines"
  type        = string
  default     = "Standard_B1s"
}


