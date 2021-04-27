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
  /*access_policy = [{
    application_id = var.client_id
    object_id      = var.client_id
    tenant_id      = var.tenant_id
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
      "backup",
      "delete",
      "deletesas",
      "get",
      "getsas",
      "list",
      "listsas",
      "purge",
      "recover",
      "regeneratekey",
      "restore",
      "set",
      "setsas",
      "update"
    ]
  }]*/
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

resource "azurerm_role_assignment" "key_vault" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.object_id
}

resource "azurerm_key_vault_secret" "mysql_secret" {
  name         = "mysqlsecret"
  value        = random_string.mysql_admin_password.result
  key_vault_id = azurerm_key_vault.key_vault.id
}

resource "azurerm_role_assignment" "key_vault" {
  scope                = azurerm_key_vault.key_vault.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_mysql_server.mysql_server.identity[0].principal_id
}
/*
resource "azurerm_key_vault_access_policy" "mssql_access_policy" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = azurerm_mysql_server.mysql_server.identity[0].tenant_id
  object_id    = azurerm_mysql_server.mysql_server.identity[0].principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}*/