locals {
  frontend_endpoint_host_name = lower("${var.aks_cluster_name}frntdr${var.environment}.azurefd.net")
}

resource "azurerm_frontdoor" "frontdoor" {
  name                                         = lower("${var.aks_cluster_name}frntdr${var.environment}")
  resource_group_name                          = var.resource_group_name
  enforce_backend_pools_certificate_name_check = false

  frontend_endpoint {
    name                     = "K8sFrontendEndpoint"
    host_name                = local.frontend_endpoint_host_name
    session_affinity_enabled = false
    #session_affinity_ttl_seconds = 300
  }
  backend_pool {
    name = "K8sBackendPool"
    backend {
      host_header = azurerm_public_ip.inbound_kubernetes_cluster_public_ip.ip_address
      address     = azurerm_public_ip.inbound_kubernetes_cluster_public_ip.ip_address
      http_port   = 80
      https_port  = 443
      priority    = 1
      weight      = 100
    }

    load_balancing_name = "K8sLoadBalancingSettings"
    health_probe_name   = "K8sHealthProbeSetting"
  }
  backend_pool_health_probe {
    name    = "K8sHealthProbeSetting"
    enabled = false
    #path                = "/"
    #protocol            = "Http"
    #probe_method        = "GET"
    #interval_in_seconds = 10
  }
  backend_pool_load_balancing {
    name                            = "K8sLoadBalancingSettings"
    sample_size                     = 4
    successful_samples_required     = 2
    additional_latency_milliseconds = 0
  }
  routing_rule {
    name               = "K8sRoutingRule"
    enabled            = true
    accepted_protocols = ["Http", "Https"]
    frontend_endpoints = ["K8sFrontendEndpoint"]
    patterns_to_match  = ["/*"]
    forwarding_configuration {
      backend_pool_name   = "K8sBackendPool"
      forwarding_protocol = "HttpOnly"
    }
  }
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}