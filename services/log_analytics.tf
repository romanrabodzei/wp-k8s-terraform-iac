resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
  name                = lower("${var.aks_cluster_name}loganalytics${var.environment}")
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 30

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}