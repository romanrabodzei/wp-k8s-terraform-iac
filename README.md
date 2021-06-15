## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | =2.46.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | =2.46.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_policies"></a> [policies](#module\_policies) | ./policies | n/a |
| <a name="module_services"></a> [services](#module\_services) | ./services | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/2.46.0/docs/resources/resource_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aks_cluster_name"></a> [aks\_cluster\_name](#input\_aks\_cluster\_name) | Azure Kubernetes Cluster name | `string` | n/a | yes |
| <a name="input_client"></a> [client](#input\_client) | Client company name | `string` | n/a | yes |
| <a name="input_client_id"></a> [client\_id](#input\_client\_id) | Client Id | `string` | n/a | yes |
| <a name="input_client_secret"></a> [client\_secret](#input\_client\_secret) | Client Secret | `string` | n/a | yes |
| <a name="input_company"></a> [company](#input\_company) | Integity Vision | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment: Dev, Test, Stage, Prod | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The geographic location of the resources | `string` | n/a | yes |
| <a name="input_object_id"></a> [object\_id](#input\_object\_id) | Object Id | `string` | n/a | yes |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Subscription Id | `string` | n/a | yes |
| <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id) | Tenant Id | `string` | n/a | yes |

## Outputs

No outputs.
