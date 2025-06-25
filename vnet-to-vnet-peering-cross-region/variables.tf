variable "use_cli_auth" {
  description = "Set to true to authenticate to Azure using the Azure CLI. False will require environment variables or service principal."
  type        = bool
  default     = true
}

variable "resource_group_name" {
  description = "Name of the Azure Resource Group."
  type        = string
  default     = "vnet-peering-rg"
}

# --- VNet1 Variables ---
variable "vnet1_name" {
  description = "Name of Virtual Network 1."
  type        = string
  default     = "vnet1"
}

variable "vnet1_location" {
  description = "Azure region for Virtual Network 1 and Server 1."
  type        = string
  default     = "France Central"
}

variable "vnet1_address_space" {
  description = "Address space for Virtual Network 1 (CIDR)."
  type        = string
  default     = "10.1.0.0/16"
}

variable "vnet1_subnet_name" {
  description = "Name of the subnet for VNet1."
  type        = string
  default     = "default"
}

variable "vnet1_subnet_address_prefix" {
  description = "Address prefix for the subnet in VNet1 (CIDR)."
  type        = string
  default     = "10.1.1.0/24"
}


variable "vnet2_name" {
  description = "Name of Virtual Network 2."
  type        = string
  default     = "vnet2"
}

variable "vnet2_location" {
  description = "Azure region for Virtual Network 2 and Server 2."
  type        = string
  default     = "East US"
}

variable "vnet2_address_space" {
  description = "Address space for Virtual Network 2 (CIDR)."
  type        = string
  default     = "20.1.0.0/16"
}

variable "vnet2_subnet_name" {
  description = "Name of the subnet for VNet2."
  type        = string
  default     = "default"
}

variable "vnet2_subnet_address_prefix" {
  description = "Address prefix for the subnet in VNet2 (CIDR)."
  type        = string
  default     = "20.1.1.0/24"
}


variable "vm_size" {
  description = "Size of the virtual machines."
  type        = string
  default     = "Standard_B1s"
}

variable "vm_admin_username" {
  description = "Admin username for the virtual machines."
  type        = string
  default     = "learning"
}

variable "vm_admin_password" {
  description = "Admin password for the virtual machines. Use a strong password!"
  type        = string
  sensitive   = true
  default     = "Redhat@12345"
}

variable "os_disk_type" {
  description = "Storage account type for the OS disk (e.g., Standard_LRS, Premium_LRS)."
  type        = string
  default     = "Standard_LRS"
}

variable "os_disk_size_gb" {
  description = "Size of the OS disk in GB."
  type        = number
  default     = 30
}

variable "vm_image_publisher" {
  description = "Publisher of the VM image."
  type        = string
  default     = "Canonical"
}

variable "vm_image_offer" {
  description = "Offer of the VM image."
  type        = string
  default     = "0001-com-ubuntu-server-jammy"
}

variable "vm_image_sku" {
  description = "SKU of the VM image. (e.g., 22_04-lts, 24_04-lts-gen2)"
  type        = string
  default     = "22_04-lts"
}

variable "vm_image_version" {
  description = "Version of the VM image."
  type        = string
  default     = "latest"
}


variable "server1_name" {
  description = "Name of Virtual Machine 1."
  type        = string
  default     = "server1"
}
variable "server1_nsg_name" {
  description = "Name of the Network Security Group for Server 1."
  type        = string
  default     = "nsg-server1"
}
variable "server1_public_ip_name" {
  description = "Name of the Public IP for Server 1."
  type        = string
  default     = "server1-public-ip"
}
variable "server1_nic_name" {
  description = "Name of the Network Interface for Server 1."
  type        = string
  default     = "server1-nic"
}

variable "server2_name" {
  description = "Name of Virtual Machine 2."
  type        = string
  default     = "server2"
}
variable "server2_nsg_name" {
  description = "Name of the Network Security Group for Server 2."
  type        = string
  default     = "nsg-server2"
}
variable "server2_public_ip_name" {
  description = "Name of the Public IP for Server 2."
  type        = string
  default     = "server2-public-ip"
}
variable "server2_nic_name" {
  description = "Name of the Network Interface for Server 2."
  type        = string
  default     = "server2-nic"
}


