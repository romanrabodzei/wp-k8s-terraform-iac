resource "azuread_group" "kubernetes_admin_group" {
  display_name = "Kubernetes Admins"
  members = [
    data.azurerm_client_config.current.object_id
  ]
}

resource "random_string" "kubernetes_cluster_sp_password" {
  length  = 24
  special = false
}

resource "random_string" "kubernetes_cluster_sp_secret" {
  length  = 24
  special = false
}

resource "azuread_application" "kubernetes_cluster_sp" {
  display_name = lower("${var.aks_cluster_name}sp${var.environment}")
}

resource "azuread_application_password" "kubernetes_cluster_sp" {
  application_object_id = azuread_application.kubernetes_cluster_sp.id
  value                 = random_string.kubernetes_cluster_sp_secret.result
  end_date_relative     = "8760h"

  lifecycle {
    ignore_changes = [
      value,
      end_date_relative
    ]
  }
}

resource "azuread_service_principal" "kubernetes_cluster_sp" {
  application_id               = azuread_application.kubernetes_cluster_sp.application_id
  app_role_assignment_required = false
}

resource "azuread_service_principal_password" "kubernetes_cluster_sp" {
  service_principal_id = azuread_service_principal.kubernetes_cluster_sp.id
  value                = random_string.kubernetes_cluster_sp_password.result
  end_date_relative    = "8760h"

  lifecycle {
    ignore_changes = [
      value,
      end_date_relative
    ]
  }
}

resource "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  name                = lower("${var.aks_cluster_name}${var.environment}")
  resource_group_name = var.resource_group_name
  location            = var.location
  dns_prefix          = lower("${var.aks_cluster_name}${var.environment}")
  #private_cluster_enabled = true
  default_node_pool {
    name       = "agentpool"
    node_count = "1"
    vm_size    = "Standard_DS2_v2"
    availability_zones = [
      1, 2, 3
    ]
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = true
    max_count           = 10
    min_count           = 1
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
    http_application_routing {
      enabled = true
    }
  }

  service_principal {
    client_id     = azuread_service_principal.kubernetes_cluster_sp.application_id
    client_secret = random_string.kubernetes_cluster_sp_password.result
  }

  role_based_access_control {
    enabled = true
    azure_active_directory {
      managed = true
      admin_group_object_ids = [ azuread_group.kubernetes_admin_group.object_id ]
    }
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
    load_balancer_profile {
      outbound_ip_address_ids = [azurerm_public_ip.outbound_kubernetes_cluster_public_ip.id]
    }
  }

  depends_on = [
    azuread_service_principal.kubernetes_cluster_sp
  ]
  lifecycle {
    ignore_changes = [
      tags,
      default_node_pool
    ]
  }
}

resource "azurerm_public_ip" "outbound_kubernetes_cluster_public_ip" {
  name                = lower("${var.aks_cluster_name}pip${var.environment}")
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_role_assignment" "kubernetes_cluster_outbound_pip_role_assignment" {
  scope                = azurerm_public_ip.outbound_kubernetes_cluster_public_ip.id
  role_definition_name = "Network Contributor"
  principal_id         = azuread_service_principal.kubernetes_cluster_sp.object_id
}

resource "azurerm_public_ip" "inbound_kubernetes_cluster_public_ip" {
  name                = lower("${var.aks_cluster_name}sip${var.environment}")
  resource_group_name = "MC_${var.resource_group_name}_${azurerm_kubernetes_cluster.kubernetes_cluster.name}_${var.location}"
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_role_assignment" "kubernetes_cluster_inbound_pip_role_assignment" {
  scope                = azurerm_public_ip.inbound_kubernetes_cluster_public_ip.id
  role_definition_name = "Network Contributor"
  principal_id         = azuread_service_principal.kubernetes_cluster_sp.object_id
}

resource "azurerm_role_assignment" "kubernetes_cluster_registry_role_assignment" {
  scope                = azurerm_container_registry.container_registry.id
  role_definition_name = "AcrPull"
  principal_id         = azuread_service_principal.kubernetes_cluster_sp.object_id
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