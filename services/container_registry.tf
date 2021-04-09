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

resource "azurerm_monitor_diagnostic_setting" "container_registry_diagnostic_setting" {
  name                       = lower("${var.aks_cluster_name}-sa-${var.environment}-diagsettings")
  target_resource_id         = azurerm_container_registry.container_registry.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  log {
    category = "ContainerRegistryRepositoryEvents"
    enabled  = true
  }
  log {
    category = "ContainerRegistryLoginEvents"
    enabled  = true
  }
  metric {
    category = "AllMetrics"
    enabled  = true
  }
  lifecycle {
    ignore_changes = [
      metric,
      log
    ]
  }
}