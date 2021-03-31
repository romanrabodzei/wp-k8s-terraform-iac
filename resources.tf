/*
locals {
  remote_resource_group_name  = data.terraform_remote_state.main.outputs.resource_group_name
  remote_virtual_network_name = data.terraform_remote_state.main.outputs.network_name
  remote_virtual_network_id   = data.terraform_remote_state.main.outputs.network_id
}
*/

resource "azurerm_resource_group" "resource_group" {
  name     = lower("rg-${var.company}-${var.client}-${var.environment}")
  location = var.location
}

module "policies" {
  source              = "./policies"
  resource_group_name = azurerm_resource_group.resource_group.name
  resource_group_id   = azurerm_resource_group.resource_group.id
  #Tags Values
  company     = var.company
  client      = var.client
  environment = var.environment
  location    = var.location
}

module "services" {
  source              = "./services"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = var.location
  environment         = var.environment
  aks_cluster_name    = var.aks_cluster_name
  # Remote information
  #remote_resource_group_name  = local.remote_resource_group_name
  #remote_virtual_network_name = local.remote_virtual_network_name
  #remote_virtual_network_id   = local.remote_virtual_network_id
  # Subnet for Azure Kubernetes Cluster
  aks_subnet_name    = var.aks_subnet_name
  aks_subnet_address = var.aks_subnet_address
  # Subnet for services
  srv_subnet_name    = var.srv_subnet_name
  srv_subnet_address = var.srv_subnet_address
  # Tags will be applyed on resources during resource creation
  depends_on = [
    module.policies.azurerm_tag_policy_assignment_id
  ]
}
