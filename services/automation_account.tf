resource "azurerm_automation_account" "automation_account" {
  name                = lower("${var.aks_cluster_name}autoacc${var.environment}")
  resource_group_name = var.resource_group_name
  location            = var.location
  sku_name            = "Basic"

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}


/*
# Automation Account runbooks
data "local_file" "example" {
  filename = "${path.module}/example.ps1"
}

resource "azurerm_automation_runbook" "example" {
  name                    = "Get-AzureVMTutorial"
  location                = azurerm_resource_group.example.location
  resource_group_name     = azurerm_resource_group.example.name
  automation_account_name = azurerm_automation_account.example.name
  log_verbose             = "true"
  log_progress            = "true"
  description             = "This is an example runbook"
  runbook_type            = "PowerShell"

  content = data.local_file.example.content
}

resource "azurerm_automation_job_schedule" "example" {
  resource_group_name     = "tf-rgr-automation"
  automation_account_name = "tf-automation-account"
  schedule_name           = "hour"
  runbook_name            = "Get-VirtualMachine"

  parameters = {
    resourcegroup = "tf-rgr-vm"
    vmname        = "TF-VM-01"
  }
}
*/

resource "azurerm_monitor_diagnostic_setting" "automation_account_diagnostic_setting" {
  name                       = lower("${var.aks_cluster_name}-sa-${var.environment}-diagsettings")
  target_resource_id         = azurerm_automation_account.automation_account.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.log_analytics_workspace.id
  log {
    category = "JobLogs"
    enabled  = true
  }
  log {
    category = "JobStreams"
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