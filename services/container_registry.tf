resource "azurerm_container_registry" "container_registry" {
  name                = lower("${var.aks_cluster_name}cregistry${var.environment}")
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Premium"
  admin_enabled       = true
  network_rule_set {
    default_action = "Deny"
    ip_rule {
      action   = "Allow"
      ip_range = azurerm_public_ip.outbound_kubernetes_cluster_public_ip.ip_address
    }
    ip_rule {
      action   = "Allow"
      ip_range = chomp(data.http.myip.body)
    }
  }
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}