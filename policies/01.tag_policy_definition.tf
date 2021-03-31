resource "random_string" "definition_id" {
  length  = 36
  special = false
}


resource "azurerm_policy_definition" "tags_policy" {
  name         = random_string.definition_id.result
  policy_type  = "Custom"
  mode         = "All"
  display_name = "Add or replace tags on resources"
  description  = "Adds or replaces the specified tags and values when any resource is created or updated. Existing resources can be remediated by triggering a remediation task."

  policy_rule = <<POLICY_RULE
{
  "if": {
    "allOf": [
      {
        "field": "[concat('tags[', parameters('tagName01'), ']')]", 
        "notEquals": "[parameters('tagValue01')]"
      },
      {
        "field": "[concat('tags[', parameters('tagName02'), ']')]",
        "notEquals": "[parameters('tagValue02')]"
      },
      {
        "field": "[concat('tags[', parameters('tagName03'), ']')]",
        "notEquals": "[parameters('tagValue03')]"
      },
      {
        "field": "[concat('tags[', parameters('tagName04'), ']')]",
        "notEquals": "[parameters('tagValue04')]"
      },
      {
        "field": "[concat('tags[', parameters('tagName05'), ']')]",
        "notEquals": "[parameters('tagValue05')]"
      }
    ]
  },
  "then": {
    "effect": "modify",
    "details": {
      "roleDefinitionIds": [
        "/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c"
      ],
      "operations": [
        {
          "operation": "addOrReplace",
          "field": "[concat('tags[', parameters('tagName01'), ']')]",
          "value": "[parameters('tagValue01')]"
        },
        {
          "operation": "addOrReplace",
          "field": "[concat('tags[', parameters('tagName02'), ']')]",
          "value": "[parameters('tagValue02')]"
        },
        {
          "operation": "addOrReplace",
          "field": "[concat('tags[', parameters('tagName03'), ']')]",
          "value": "[parameters('tagValue03')]"
        },
        {
          "operation": "addOrReplace",
          "field": "[concat('tags[', parameters('tagName04'), ']')]",
          "value": "[parameters('tagValue04')]"
        },
        {
          "operation": "addOrReplace",
          "field": "[concat('tags[', parameters('tagName05'), ']')]",
          "value": "[parameters('tagValue05')]"
        }
      ]
    }
  }
}
POLICY_RULE

  parameters = <<PARAMETERS
{
  "tagName01": {
    "type": "String"
  },
  "tagValue01": {
    "type": "String"
  },
  "tagName02": {
    "type": "String"
  },
  "tagValue02": {
    "type": "String"
  },
  "tagName03": {
    "type": "String"
  },
  "tagValue03": {
    "type": "String"
  },
  "tagName04": {
    "type": "String"
  },
  "tagValue04": {
    "type": "String"
  },
  "tagName05": {
    "type": "String"
  },
  "tagValue05": {
    "type": "String"
  }
}
PARAMETERS
}