
terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.78.0"
    }
  }
}

locals {
  instance_id         = var.instance_id != "" ? var.instance_id : random_id.instance_id[0].hex
  name                = "${var.name}${substr(replace(local.suffix, "-", ""), 0, 31)}${local.instance_id}"
  resource_group_name = var.resource_group_name != "" ? var.resource_group_name : azurerm_resource_group.rg[0].name
  suffix              = "${lower(var.env)}-${replace(lower(var.location), " ", "")}"
}

resource "random_id" "instance_id" {
  count    = var.instance_id == "" ? 1 : 0

  byte_length = 4
}

resource "azurerm_resource_group" "rg" {
  count    = var.resource_group_name == "" ? 1 : 0

  name     = "rg-${var.name}-${local.suffix}"
  location = var.location

  tags = var.tags
}

# Need to get other attributes such as ID, and it was cleaner to do this instead of using locals...
data "azurerm_log_analytics_workspace" "log" {
  name                = var.log_analytics_workspace_name
  resource_group_name = var.log_analytics_resource_group_name
}

resource "azurerm_automation_account" "automation" {
  name                = "${local.name}"
  location            = data.azurerm_log_analytics_workspace.log.location
  resource_group_name = data.azurerm_log_analytics_workspace.log.resource_group_name

  sku_name = var.sku_name

  tags = var.tags
}

resource "azurerm_log_analytics_linked_service" "log_link" {
  resource_group_name = data.azurerm_log_analytics_workspace.log.resource_group_name
  workspace_id        = data.azurerm_log_analytics_workspace.log.id
  read_access_id      = azurerm_automation_account.automation.id
}

resource "azurerm_log_analytics_solution" "log_solution_updates" {
  count                 = var.enable_update_management ? 1 : 0
  resource_group_name   = data.azurerm_log_analytics_workspace.log.resource_group_name
  location              = var.location

  solution_name         = "Updates"
  workspace_resource_id = data.azurerm_log_analytics_workspace.log.id
  workspace_name        = data.azurerm_log_analytics_workspace.log.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Updates"
  }

  depends_on = [
    azurerm_log_analytics_linked_service.log_link
  ]
}

# When updating the template deployment, we need to reset the start time
# Otherwise, Error: The start time of the schedule must be at least 5 minutes after the time you create the schedule.
resource "time_offset" "update_start_time" {
  triggers = {
    automation_name = azurerm_automation_account.automation.name
    enable_definition_updates = var.enable_definition_updates
    enable_monthly_updates = var.enable_monthly_updates
    enable_update_management = var.enable_update_management
    log_rg_name = data.azurerm_log_analytics_workspace.log.resource_group_name
    name = local.name
    timezone = var.timezone
    update_scope = var.update_scope
  }

  offset_days = 1
}

locals {
  update_start_time = "${time_offset.update_start_time.year}-${format("%02d", time_offset.update_start_time.month)}-${format("%02d", time_offset.update_start_time.day)}T${var.update_start_time}Z"
}

resource "azurerm_template_deployment" "windows_update_definition" {
  count                 = var.enable_update_management && var.enable_definition_updates ? 1 : 0

  name                = "${local.name}-definitionUpdates"
  resource_group_name = data.azurerm_log_analytics_workspace.log.resource_group_name

  template_body = <<EOF
  {
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {},
    "variables": {},
    "resources": [
      {
        "type": "Microsoft.Automation/automationAccounts/softwareUpdateConfigurations",
        "apiVersion": "2019-06-01",
        "name": "${azurerm_automation_account.automation.name}/Definition Updates",
        "properties": {
          "updateConfiguration": {
            "operatingSystem": "Windows",
            "windows": {
              "includedUpdateClassifications": "Definition",
              "excludedKbNumbers": [],
              "includedKbNumbers": [],
              "rebootSetting": "Never"
            },
            "targets": {
              "azureQueries": [
                {
                  "scope": [
                    "${var.update_scope}"
                  ],
                  "tagSettings": {
                    "tags": {},
                    "filterOperator": "All"
                  },
                  "locations": []
                }
              ]
            },
            "duration": "PT30M",
            "azureVirtualMachines": [],
            "nonAzureComputerNames": []
          },
          "tasks": {},
          "scheduleInfo": {
            "frequency": "Hour",
            "startTime": "${local.update_start_time}",
            "expiryTime": "9999-12-31T23:59:59.9999999+00:00",
            "timeZone": "${var.timezone}",
            "interval": 2
          }
        }
      }
    ]
  }
  EOF

  deployment_mode = "Incremental"

  depends_on = [
    azurerm_automation_account.automation,
  ]
}

resource "azurerm_template_deployment" "windows_update_monthly" {
  for_each            = {for schedule in var.update_schedule: schedule.scope => schedule}

  name                = "${local.name}-monthlyUpdates"
  resource_group_name = data.azurerm_log_analytics_workspace.log.resource_group_name

  template_body = <<EOF
  {
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {},
    "variables": {},
    "resources": [
      {
        "type": "Microsoft.Automation/automationAccounts/softwareUpdateConfigurations",
        "apiVersion": "2019-06-01",
        "name": "${azurerm_automation_account.automation.name}/Monthly Updates",
        "properties": {
          "updateConfiguration": {
            "operatingSystem": "Windows",
            "windows": {
              "includedUpdateClassifications": "Critical, Security, UpdateRollup, FeaturePack, ServicePack, Definition, Tools, Updates",
              "excludedKbNumbers": [],
              "includedKbNumbers": [],
              "rebootSetting": "IfRequired"
            },
            "targets": {
              "azureQueries": [
                {
                  "scope": [
                    "${each.value.scope}"
                  ],
                  "tagSettings": {
                    "tags": {},
                    "filterOperator": "All"
                  },
                  "locations": []
                }
              ]
            },
            "duration": "PT2H",
            "azureVirtualMachines": [],
            "nonAzureComputerNames": []
          },
          "tasks": {},
          "scheduleInfo": {
            "frequency": "Week",
            "startTime": "${time_offset.update_start_time.year}-${format("%02d", time_offset.update_start_time.month)}-${format("%02d", time_offset.update_start_time.day)}T${each.value.start_time}Z",
            "expiryTime": "9999-12-31T23:59:59.9999999+00:00",
            "timeZone": "${var.timezone}",
            "interval": 1,
            "advancedSchedule": {
              "weekDays": ${jsonencode(each.value.week_days)}
            }
          }
        }
      }
    ]
  }
  EOF

  deployment_mode = "Incremental"

  depends_on = [
    azurerm_automation_account.automation,
  ]
}

resource "azurerm_log_analytics_solution" "log_solution_change_tracking" {
  count                 = var.enable_change_tracking ? 1 : 0
  resource_group_name   = data.azurerm_log_analytics_workspace.log.resource_group_name
  location              = var.location

  solution_name         = "ChangeTracking"
  workspace_resource_id = data.azurerm_log_analytics_workspace.log.id
  workspace_name        = data.azurerm_log_analytics_workspace.log.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ChangeTracking"
  }

  depends_on = [
    azurerm_log_analytics_linked_service.log_link
  ]
}

resource "azurerm_monitor_diagnostic_setting" "logs" {
  name                       = "automation_logs"
  target_resource_id         = azurerm_automation_account.automation.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log.id

  log {
    category = "AuditEvent"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "JobLogs"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "JobStreams"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "DscNodeStatus"
    enabled  = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }
}


resource "azurerm_monitor_diagnostic_setting" "metrics" {
  name                       = "automation_metrics"
  target_resource_id         = azurerm_automation_account.automation.id
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.log.id

  log {
    category = "AuditEvent"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "JobLogs"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "JobStreams"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  log {
    category = "DscNodeStatus"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"
    enabled = true

    retention_policy {
      days    = 0
      enabled = false
    }
  }
}