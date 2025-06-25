output "public_subnet_details" {
  description = "Details of all public subnets"
  value = [
    for subnet in azurerm_subnet.public_subnets : {
      address_prefix = subnet.address_prefixes[0]
    }
  ]
}

output "private_subnet_details" {
  description = "Details of all private subnets"
  value = [
    for subnet in azurerm_subnet.private_subnets : {
      address_prefix = subnet.address_prefixes[0]
    }
  ]
}
