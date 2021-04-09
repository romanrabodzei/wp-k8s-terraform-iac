data "azurerm_client_config" "current" {}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "azurerm_key_vault" "key_vault" {
  name                            = lower("${var.aks_cluster_name}keyvault${var.environment}")
  resource_group_name             = var.resource_group_name
  location                        = var.location
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = "premium"
  enabled_for_template_deployment = true
  enable_rbac_authorization       = false
  soft_delete_retention_days      = 14
  access_policy = [{
    application_id = data.azurerm_client_config.current.client_id
    object_id      = data.azurerm_client_config.current.object_id
    tenant_id      = data.azurerm_client_config.current.tenant_id
    key_permissions = [
      "Backup",
      "Create",
      "Delete",
      "Get",
      "Import",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Update"
    ]
    secret_permissions = [
      "Backup",
      "Delete",
      "Get",
      "List",
      "Purge",
      "Recover",
      "Restore",
      "Set"
    ]
    certificate_permissions = [
      "Backup",
      "Create",
      "Delete",
      "DeleteIssuers",
      "Get",
      "GetIssuers",
      "Import",
      "List",
      "ListIssuers",
      "ManageContacts",
      "ManageIssuers",
      "Purge",
      "Recover",
      "Restore",
      "SetIssuers",
      "Update"
    ]
    storage_permissions = [
      "Backup",
      "Delete",
      "DeleteSAS",
      "Get",
      "GetSAS",
      "List",
      "ListSAS",
      "Purge",
      "Recover",
      "RegenerateKey",
      "Restore",
      "Set",
      "SetSAS",
      "Update"
    ]
  }]
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules = ["${chomp(data.http.myip.body)}/32",
    azurerm_public_ip.outbound_kubernetes_cluster_public_ip.ip_address]
  }
  lifecycle {
    ignore_changes = [
      tags,
      access_policy
    ]
  }
  depends_on = [
    data.http.myip
  ]
}

# AKV secrets and access policies
resource "azurerm_key_vault_secret" "mssql_secret" {
  name         = "mssqlsecret"
  value        = random_string.mssql_admin_password.result
  key_vault_id = azurerm_key_vault.key_vault.id
}
resource "azurerm_key_vault_access_policy" "mssql_access_policy" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = azurerm_mssql_server.mssql_server.identity[0].tenant_id
  object_id    = azurerm_mssql_server.mssql_server.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}

resource "azurerm_monitor_diagnostic_setting" "key_vault_diagnostic_setting" {
  name                       = lower("${var.aks_cluster_name}-sa-${var.environment}-diagsettings")
  target_resource_id         = azurerm_key_vault.key_vault.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  log {
    category = "AuditEvent"
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