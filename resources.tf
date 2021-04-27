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
  subscription_id     = var.subscription_id
  object_id           = var.object_id
  client_id           = var.client_id
  tenant_id           = var.tenant_id
  depends_on = [
    module.policies.azurerm_tag_policy_assignment_id
  ]
}
