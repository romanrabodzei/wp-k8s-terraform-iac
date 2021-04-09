resource "azuread_group" "sql_admin_group" {
  display_name = "SQL Admins"
  members = [
    data.azurerm_client_config.current.object_id
  ]
}

resource "random_string" "mssql_admin_password" {
  length  = 12
  special = false
}

resource "azurerm_mssql_server" "mssql_server" {
  name                          = lower("${var.aks_cluster_name}mssqlsrv${var.environment}")
  resource_group_name           = var.resource_group_name
  location                      = var.location
  administrator_login           = "azuresqladmin"
  administrator_login_password  = random_string.mssql_admin_password.result
  version                       = "12.0"
  public_network_access_enabled = true
  minimum_tls_version           = "1.2"
  connection_policy             = "Default"
  azuread_administrator {
    login_username = azuread_group.sql_admin_group.name
    object_id      = azuread_group.sql_admin_group.object_id
  }
  identity {
    type = "SystemAssigned"
  }
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_mssql_firewall_rule" "mssql_firewall_rule_azure_services" {
  name             = "AllowAzureservices"
  server_id        = azurerm_mssql_server.mssql_server.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_firewall_rule" "mssql_firewall_rule_managed_ip" {
  name             = "ManagedIP"
  server_id        = azurerm_mssql_server.mssql_server.id
  start_ip_address = chomp(data.http.myip.body)
  end_ip_address   = chomp(data.http.myip.body)
}

resource "azurerm_mssql_firewall_rule" "mssql_firewall_rule_cluster_ip" {
  name             = "K8sIP"
  server_id        = azurerm_mssql_server.mssql_server.id
  start_ip_address = azurerm_public_ip.outbound_kubernetes_cluster_public_ip.ip_address
  end_ip_address   = azurerm_public_ip.outbound_kubernetes_cluster_public_ip.ip_address
}

resource "azurerm_mssql_server_extended_auditing_policy" "mssql_server_extended_auditing_policy" {
  server_id              = azurerm_mssql_server.mssql_server.id
  log_monitoring_enabled = true
}

resource "azurerm_mssql_database" "mssqldatabase" {
  name                 = lower("${var.aks_cluster_name}mssqldb${var.environment}")
  server_id            = azurerm_mssql_server.mssql_server.id
  create_mode          = "Default"
  collation            = "SQL_Latin1_General_CP1_CI_AS"
  license_type         = "BasePrice"
  max_size_gb          = 150
  read_replica_count   = 0
  read_scale           = false
  sku_name             = "S0" # Basic,S0, P2, GP_S_Gen5_2, HS_Gen4_1, BC_Gen5_2, ElasticPool, DW100c, DS100
  storage_account_type = "LRS"
  zone_redundant       = false
  /*
  long_term_retention_policy {
    monthly_retention = (known after apply)
    week_of_year      = (known after apply)
    weekly_retention  = (known after apply)
    yearly_retention  = (known after apply)
  }

  short_term_retention_policy {
    retention_days = (known after apply)
  }
  */
  lifecycle {
    ignore_changes = [
      tags, license_type
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "mssqldatabase_diagnostic_setting" {
  name                       = lower("${var.aks_cluster_name}-mssqldb-${var.environment}-diagsettings")
  target_resource_id         = azurerm_mssql_database.mssqldatabase.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  log {
    category = "SQLSecurityAuditEvents"
    enabled  = true
    retention_policy {
      enabled = false
    }
  }

  log {
    category = "AutomaticTuning"
    enabled  = true
    retention_policy {
      enabled = false
    }
  }
  log {
    category = "QueryStoreRuntimeStatistics"
    enabled  = true
    retention_policy {
      enabled = false
    }
  }
  log {
    category = "QueryStoreWaitStatistics"
    enabled  = true
    retention_policy {
      enabled = false
    }
  }
  log {
    category = "Errors"
    enabled  = true
    retention_policy {
      enabled = false
    }
  }
  log {
    category = "DatabaseWaitStatistics"
    enabled  = true
    retention_policy {
      enabled = false
    }
  }
  log {
    category = "Timeouts"
    enabled  = true
    retention_policy {
      enabled = false
    }
  }
  log {
    category = "Blocks"
    enabled  = true
    retention_policy {
      enabled = false
    }
  }
  log {
    category = "Deadlocks"
    enabled  = true
    retention_policy {
      enabled = false
    }
  }
  log {
    category = "SQLInsights"
    enabled  = true
    retention_policy {
      enabled = false
    }
  }
  metric {
    category = "Basic"
    enabled  = true
    retention_policy {
      enabled = false
    }
  }
  metric {
    category = "InstanceAndAppAdvanced"
    enabled  = true
    retention_policy {
      enabled = false
    }
  }
  metric {
    category = "WorkloadManagement"
    enabled  = true
    retention_policy {
      enabled = false
    }
  }
  lifecycle {
    ignore_changes = [
      log,
      metric
    ]
  }
}

resource "azurerm_mssql_database_extended_auditing_policy" "mssqldatabase_extended_auditing_policy" {
  database_id            = azurerm_mssql_database.mssqldatabase.id
  log_monitoring_enabled = true
}

resource "azurerm_log_analytics_solution" "mssqldatabase_log_analytics_solution" {
  solution_name         = "AzureSQLAnalytics"
  resource_group_name   = var.resource_group_name
  location              = var.location
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics_workspace.name
  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/AzureSQLAnalytics"
  }
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}