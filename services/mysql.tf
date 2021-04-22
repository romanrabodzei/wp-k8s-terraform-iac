resource "azuread_group" "sql_admin_group" {
  display_name = "SQL ${var.environment} Admins"
  members = [
    data.azurerm_client_config.current.object_id
  ]
}

resource "random_string" "mysql_admin_password" {
  length           = 16
  special          = true
  override_special = "!@#$"
}

resource "azurerm_mysql_server" "mysql_server" {
  name                = lower("${var.aks_cluster_name}mysqlsrv${var.environment}")
  resource_group_name = var.resource_group_name
  location            = var.location

  administrator_login          = "azuresqladmin"
  administrator_login_password = random_string.mysql_admin_password.result

  sku_name   = "B_Gen5_2"
  storage_mb = 5120
  version    = "5.7"

  create_mode                       = "Default"
  auto_grow_enabled                 = true
  backup_retention_days             = 7
  geo_redundant_backup_enabled      = false
  infrastructure_encryption_enabled = false
  public_network_access_enabled     = true
  ssl_enforcement_enabled           = true
  ssl_minimal_tls_version_enforced  = "TLS1_2"

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_mysql_active_directory_administrator" "azurerm_mysql_firewall_rule" {
  server_name         = azurerm_mysql_server.mysql_server.name
  resource_group_name = var.resource_group_name
  login               = azuread_group.sql_admin_group.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = azuread_group.sql_admin_group.object_id
}

resource "azurerm_mysql_database" "mysql_database" {
  name                = lower("${var.aks_cluster_name}mysqldb${var.environment}")
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.mysql_server.name
  charset             = "utf8"
  collation           = "utf8_unicode_ci"
}

resource "azurerm_mysql_firewall_rule" "mysql_firewall_rule_azure_services" {
  name                = "AllowAzureservices"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.mysql_server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

resource "azurerm_mysql_firewall_rule" "mysql_firewall_rule_managed_ip" {
  name                = "ManagedIP"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.mysql_server.name
  start_ip_address    = chomp(data.http.myip.body)
  end_ip_address      = chomp(data.http.myip.body)
}

resource "azurerm_mysql_firewall_rule" "mysql_firewall_rule_cluster_ip" {
  name                = "K8sIP"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_mysql_server.mysql_server.name
  start_ip_address    = azurerm_public_ip.outbound_kubernetes_cluster_public_ip.ip_address
  end_ip_address      = azurerm_public_ip.outbound_kubernetes_cluster_public_ip.ip_address
}