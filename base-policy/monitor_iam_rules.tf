
resource "azurerm_monitor_activity_log_alert" "create_or_update_roleAssignments" {
  name                = "Create or Update Role Assignment"
  resource_group_name = azurerm_resource_group.monitor.name
  location            = "global"
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.Authorization/roleAssignments/write events"

  criteria {
    operation_name = "Microsoft.Authorization/roleAssignments/write"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "delete_roleAssignments" {
  name                = "Delete Role Assignment"
  resource_group_name = azurerm_resource_group.monitor.name
  location            = "global"
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.Authorization/roleAssignments/delete events"

  criteria {
    operation_name = "Microsoft.Authorization/roleAssignments/delete"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "create_or_update_roleDefinitions" {
  name                = "Create or Update Role Definition"
  resource_group_name = azurerm_resource_group.monitor.name
  location            = "global"
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.Authorization/roleDefinitions/write events"

  criteria {
    operation_name = "Microsoft.Authorization/roleDefinitions/write"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "delete_roleDefinitions" {
  name                = "Delete Role Definition"
  resource_group_name = azurerm_resource_group.monitor.name
  location            = "global"
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.Authorization/roleDefinitions/delete events"

  criteria {
    operation_name = "Microsoft.Authorization/roleDefinitions/delete"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}
