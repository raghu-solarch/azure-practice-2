variable "location" {
  description = "Azure region"
  default     = "France Central"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  default     = "prod-rg"
}

variable "vnet_name" {
  description = "Name of the virtual network"
  default     = "prod-vnet"
}

variable "vnet_cidr" {
  description = "Address space for the VNet"
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet CIDRs"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnet CIDRs"
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}
