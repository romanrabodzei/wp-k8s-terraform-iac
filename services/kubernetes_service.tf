resource "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  name                = lower("${var.aks_cluster_name}${var.environment}")
  resource_group_name = var.resource_group_name
  location            = var.location
  dns_prefix          = lower("${var.aks_cluster_name}${var.environment}")

  default_node_pool {
    name       = "nodepool01"
    node_count = "1"
    vm_size    = "Standard_DS2_v2"
    availability_zones = [
      1, 2, 3
    ]
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    max_count           = 10
    min_count           = 1
    vnet_subnet_id      = azurerm_subnet.aks_subnet.id
    max_pods            = 250
  }

  addon_profile {
    azure_policy {
      enabled = true
    }
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
    }
    kube_dashboard {
      enabled = true
    }
  }


  identity {
    type = "SystemAssigned"
  }

  role_based_access_control {
    enabled = true
    #azure_active_directory {
    #  managed = false
    #admin_group_object_ids = [ "value" ]
    #}
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    network_policy    = "azure"
    #outbound_type     = "userDefinedRouting"
  }

  lifecycle {
    ignore_changes = [
      tags,
      default_node_pool[0]
    ]
  }
}

resource "azurerm_role_assignment" "kubernetes_cluster_role_assignment" {
  #scope                = var.remote_virtual_network_id
  scope                = azurerm_virtual_network.virtual_network.id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.kubernetes_cluster.identity[0].principal_id
}

resource "azurerm_log_analytics_solution" "kubernetes_cluster_log_analytics_solution" {
  solution_name         = "ContainerInsights"
  resource_group_name   = var.resource_group_name
  location              = var.location
  workspace_resource_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  workspace_name        = azurerm_log_analytics_workspace.log_analytics_workspace.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_monitor_diagnostic_setting" "kubernetes_cluster_diagnostic_setting" {
  name                       = lower("${var.aks_cluster_name}-${var.environment}-diagsettings")
  target_resource_id         = azurerm_kubernetes_cluster.kubernetes_cluster.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  log {
    category = "kube-apiserver"
    enabled  = true
  }
  log {
    category = "kube-audit"
    enabled  = true
  }
  log {
    category = "kube-audit-admin"
    enabled  = true
  }
  log {
    category = "kube-controller-manager"
    enabled  = true
  }
  log {
    category = "kube-scheduler"
    enabled  = true
  }
  log {
    category = "cluster-autoscaler"
    enabled  = true
  }
  log {
    category = "guard"
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