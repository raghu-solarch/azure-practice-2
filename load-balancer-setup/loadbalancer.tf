resource "azurerm_public_ip" "lb_public_ip" {
  name                = "myapppublicip"
  location            = local.location
  resource_group_name = local.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  sku_tier            = "Regional"
}

resource "azurerm_lb" "lb" {
  name                = "loadbalancer1"
  location            = local.location
  resource_group_name = local.resource_group_name
  sku                 = "Standard"
  sku_tier            = "Regional"

  frontend_ip_configuration {
    name                 = "myfrontendip"
    public_ip_address_id = azurerm_public_ip.lb_public_ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "bpepool" {
  name            = "myappservers"
  loadbalancer_id = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "probe" {
  name                = "myapphealthcheck"
  loadbalancer_id     = azurerm_lb.lb.id
  protocol            = "Http"
  port                = 80
  request_path        = "/"
  interval_in_seconds = 5
  number_of_probes    = 1
  probe_threshold     = 1
}

resource "azurerm_lb_rule" "lbrule" {
  name                           = "myapplbrule"
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "myfrontendip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.bpepool.id]
  probe_id                       = azurerm_lb_probe.probe.id
  disable_outbound_snat          = true
  enable_floating_ip             = false
  enable_tcp_reset               = false
  idle_timeout_in_minutes        = 4
  load_distribution              = "Default"
}
