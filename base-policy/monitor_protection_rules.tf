
resource "azurerm_monitor_activity_log_alert" "delete_resourcegroup_protection_alert" {
  name                = "Delete Resource Group"
  resource_group_name = azurerm_resource_group.monitor.name
  location            = azurerm_resource_group.monitor.location
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.Resources/subscriptions/resourceGroups/delete events"

  criteria {
    operation_name = "Microsoft.Resources/subscriptions/resourceGroups/delete"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "write_resourcegroup_protection_alert" {
  name                = "Create or Update Resource Group"
  resource_group_name = azurerm_resource_group.monitor.name
  location            = azurerm_resource_group.monitor.location
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:microsoft.insights/actionGroups/write events"

  criteria {
    operation_name = "Microsoft.Resources/subscriptions/resourceGroups/write"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "delete_management_lock_protection_alert" {
  name                = "Delete Management Lock"
  resource_group_name = azurerm_resource_group.monitor.name
  location            = azurerm_resource_group.monitor.location
  scopes              = [ "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.monitor.name}" ]
  description         = "This alert will monitor for Administrative:Microsoft.Authorization/locks/delete events in the resource group ${azurerm_monitor_action_group.action.name}"

  criteria {
    operation_name = "Microsoft.Authorization/locks/delete"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "delete_actionGroups_protection_alert" {
  name                = "Delete Action Group"
  resource_group_name = azurerm_resource_group.monitor.name
  location            = azurerm_resource_group.monitor.location
  scopes              = [ "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.monitor.name}" ]
  description         = "This alert will monitor for Administrative:microsoft.insights/actionGroups/delete events in the resource group ${azurerm_monitor_action_group.action.name}"

  criteria {
    operation_name = "microsoft.insights/actionGroups/delete"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "write_actionGroups_protection_alert" {
  name                = "Create or Update Action Group"
  resource_group_name = azurerm_resource_group.monitor.name
  location            = azurerm_resource_group.monitor.location
  scopes              = [ "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.monitor.name}" ]
  description         = "This alert will monitor for Administrative:microsoft.insights/actionGroups/write events in the resource group ${azurerm_monitor_action_group.action.name}"

  criteria {
    operation_name = "microsoft.insights/actionGroups/write"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "delete_activitylog_protection_alert" {
  name                = "Delete Activity Log Alert"
  resource_group_name = azurerm_resource_group.monitor.name
  location            = azurerm_resource_group.monitor.location
  scopes              = [ "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.monitor.name}" ]
  description         = "This alert will monitor for Administrative:microsoft.insights/activityLogAlerts/delete events in the resource group ${azurerm_monitor_action_group.action.name}"

  criteria {
    operation_name = "microsoft.insights/activityLogAlerts/delete"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "write_activitylog_protection_alert" {
  name                = "Create or Update Activity Log Alert"
  resource_group_name = azurerm_resource_group.monitor.name
  location            = azurerm_resource_group.monitor.location
  scopes              = [ "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.monitor.name}" ]
  description         = "This alert will monitor for Administrative:microsoft.insights/activityLogAlerts/write events in the resource group ${azurerm_monitor_action_group.action.name}"

  criteria {
    operation_name = "microsoft.insights/activityLogAlerts/write"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}
