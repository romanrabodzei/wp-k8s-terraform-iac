resource "azurerm_storage_account" "storage_account" {
  name                      = lower("${var.aks_cluster_name}storacc${var.environment}")
  resource_group_name       = var.resource_group_name
  location                  = var.location
  account_kind              = "StorageV2"
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  access_tier               = "Hot"
  enable_https_traffic_only = "true"
  min_tls_version           = "TLS1_2"
  allow_blob_public_access  = "false"
  network_rules {
    default_action = "Deny"
    ip_rules = [chomp(data.http.myip.body),
    azurerm_public_ip.outbound_kubernetes_cluster_public_ip.ip_address]
    bypass = [
      "Logging",
      "Metrics",
      "AzureServices"
    ]
  }
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "storage_account_diagnostic_setting" {
  name                       = lower("${var.aks_cluster_name}-sa-${var.environment}-diagsettings")
  target_resource_id         = azurerm_storage_account.storage_account.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  metric {
    category = "Capacity"
    enabled  = true
  }
  metric {
    category = "Transaction"
    enabled  = true
  }
  lifecycle {
    ignore_changes = [
      metric
    ]
  }
}