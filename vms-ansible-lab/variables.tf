variable "location" {
  default = "eastus"
}

locals {
  servers = [
    { name = "server" },
    { name = "client1" },
    { name = "client2" }
  ]
}
