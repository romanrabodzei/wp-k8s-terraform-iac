resource "azurerm_subnet" "aks_subnet" {
  name = lower("${var.aks_subnet_name}-${var.environment}")
  #resource_group_name  = var.remote_resource_group_name
  #virtual_network_name = var.remote_virtual_network_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = [var.aks_subnet_address]
  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.KeyVault",
    "Microsoft.ContainerRegistry",
    "Microsoft.Sql"
  ]
}

resource "azurerm_subnet" "srv_subnet" {
  name = lower("${var.srv_subnet_name}-${var.environment}")
  #resource_group_name  = var.remote_resource_group_name
  #virtual_network_name = var.remote_virtual_network_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  address_prefixes     = [var.srv_subnet_address]
  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.KeyVault",
    "Microsoft.ContainerRegistry",
    "Microsoft.Sql"
  ]
}

# Remote Services
resource "azurerm_network_watcher" "networkwatcher" {
  name                = "NetworkWatcher_westeurope"
  location            = var.location
  resource_group_name = var.resource_group_name
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_virtual_network" "virtual_network" {
  name                = "VirtualNetwork"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = ["172.16.0.0/16"]
  depends_on          = [azurerm_network_watcher.networkwatcher]
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}