resource "azurerm_traffic_manager_profile" "tm_profile" {
  name                   = var.traffic_manager_name
  resource_group_name    = var.resource_group_name
  traffic_routing_method = "Weighted"

  dns_config {
    relative_name = var.traffic_manager_name
    ttl           = 30
  }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/"
    interval_in_seconds          = 30
    timeout_in_seconds           = 10
    tolerated_number_of_failures = 3
  }

}

resource "azurerm_traffic_manager_external_endpoint" "endpoint1" {
  name              = "server1-endpoint"
  profile_id        = azurerm_traffic_manager_profile.tm_profile.id
  target            = azurerm_public_ip.server1_ip.fqdn
  endpoint_location = var.location_fr
  weight            = 200
}

resource "azurerm_traffic_manager_external_endpoint" "endpoint2" {
  name              = "server2-endpoint"
  profile_id        = azurerm_traffic_manager_profile.tm_profile.id
  target            = azurerm_public_ip.server2_ip.fqdn
  endpoint_location = var.location_us
  weight            = 155
}
