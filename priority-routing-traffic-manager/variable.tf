# variables.tf

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "learning"
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
  default     = "Redhat@12345"
  sensitive   = true
}

variable "domain_label_server1" {
  description = "DNS label for server1 public IP"
  type        = string
  default     = "server1-france"
}

variable "domain_label_server2" {
  description = "DNS label for server2 public IP"
  type        = string
  default     = "server2-eastus"
}

variable "traffic_manager_name" {
  description = "Name of the Traffic Manager profile"
  type        = string
  default     = "prioritytrafficmanager"
}

variable "vm_size" {
  description = "Size of the virtual machines"
  type        = string
  default     = "Standard_B1s"
}
