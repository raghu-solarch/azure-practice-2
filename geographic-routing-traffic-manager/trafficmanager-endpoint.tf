resource "azurerm_traffic_manager_profile" "tm_profile" {
  name                   = var.traffic_manager_name
  resource_group_name    = azurerm_resource_group.rg_fr.name # Any RG is fine; TM is global
  traffic_routing_method = "Geographic"

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

resource "azurerm_traffic_manager_external_endpoint" "endpoint_fr" {
  name              = "server1-fr-endpoint"
  profile_id        = azurerm_traffic_manager_profile.tm_profile.id
  target            = azurerm_public_ip.server1_ip.fqdn
  endpoint_location = var.location_fr
  geo_mappings      = ["WORLD"]
}

resource "azurerm_traffic_manager_external_endpoint" "endpoint_us" {
  name              = "server2-us-endpoint"
  profile_id        = azurerm_traffic_manager_profile.tm_profile.id
  target            = azurerm_public_ip.server2_ip.fqdn
  endpoint_location = var.location_us
  geo_mappings      = ["GEO-AS"]
}
