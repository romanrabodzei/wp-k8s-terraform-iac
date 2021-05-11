data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "azurerm_key_vault" "key_vault" {
  name                            = lower("${var.aks_cluster_name}keyvault${var.environment}")
  resource_group_name             = var.resource_group_name
  location                        = var.location
  tenant_id                       = var.tenant_id
  sku_name                        = "premium"
  enabled_for_template_deployment = true
  enable_rbac_authorization       = false
  soft_delete_retention_days      = 14
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
resource "azurerm_key_vault_access_policy" "devops_access_policy" {
  key_vault_id = azurerm_key_vault.key_vault.id
  object_id    = var.object_id
  tenant_id    = var.tenant_id

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
}

resource "azurerm_key_vault_secret" "mysql_secret" {
  name         = "mysqlsecret"
  value        = random_string.mysql_admin_password.result
  key_vault_id = azurerm_key_vault.key_vault.id
  depends_on = [
    azurerm_key_vault_access_policy.mssql_access_policy
  ]
}

resource "azurerm_key_vault_access_policy" "mssql_access_policy" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = azurerm_mysql_server.mysql_server.identity[0].tenant_id
  object_id    = azurerm_mysql_server.mysql_server.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List"
  ]

  depends_on = [
    azurerm_key_vault_access_policy.devops_access_policy
  ]
}