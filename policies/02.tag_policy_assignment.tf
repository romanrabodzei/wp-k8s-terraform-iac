locals {
  # Tags
  company     = upper(var.company)
  client      = upper(var.client)
  location    = upper(var.location)
  environment = upper(var.environment)
}
resource "random_string" "assignment_id" {
  length  = 36
  special = false
}

resource "azurerm_policy_assignment" "tags_policy_assignment" {
  name                 = random_string.assignment_id.result
  scope                = var.resource_group_id
  policy_definition_id = azurerm_policy_definition.tags_policy.id
  description          = "Adds or replaces the specified tags and values when any resource is created or updated. Existing resources can be remediated by triggering a remediation task."
  display_name         = "Add or replace tags on resources in ${var.resource_group_name} resource group"
  location             = var.location

  identity {
    type = "SystemAssigned"
  }

  metadata = <<METADATA
    {
    "category": "Tags"
    }
METADATA

  parameters = <<PARAMETERS
{
  "tagName01": {
    "type": "String",
    "value": "ENVIRONMENT"
  },
  "tagValue01": {
    "type": "String",
    "value": "${local.environment}"
  },
  "tagName02": {
    "type": "String",
    "value": "LOCATION"
  },
  "tagValue02": {
    "type": "String",
    "value": "${local.location}"
  },
  "tagName03": {
    "type": "String",
    "value": "APPLICATION"
  },
  "tagValue03": {
    "type": "String",
    "value": "CAMUNDA_BPM"
  },
  "tagName04": {
    "type": "String",
    "value": "COMPANY"
  },
  "tagValue04": {
    "type": "String",
    "value": "${local.company}"
  },
  "tagName05": {
    "type": "String",
    "value": "CLIENT"
  },
  "tagValue05": {
    "type": "String",
    "value": "${local.client}"
  }
}
PARAMETERS

  lifecycle {
    ignore_changes = all
  }
}