variable "env_name" {}
variable "vnet_cidr" {}
variable "resource_prefix" {}
variable "project_name" {}
variable "location" {}
variable "admin_username" {}
variable "admin_password" {}
variable "vm_numbers" {
  type    = set(string)
  default = []
}
