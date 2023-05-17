
resource "azurerm_monitor_activity_log_alert" "delete_policy_assignment" {
  name                = "Delete Policy Assignment"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Policy:Microsoft.Authorization/policyAssignments/delete events"

  criteria {
    operation_name = "Microsoft.Authorization/policyAssignments/delete"
    category       = "Policy"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "create_or_update_policy_assignment" {
  name                = "Create or Update Policy Assignment"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Policy:Microsoft.Authorization/policyAssignments/write events"

  criteria {
    operation_name = "Microsoft.Authorization/policyAssignments/write"
    category       = "Policy"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "deallocate_virtual_machine" {
  name                = "Deallocate Virtual Machine"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.Compute/virtualMachines/deallocate/action events"

  criteria {
    operation_name = "Microsoft.Compute/virtualMachines/deallocate/action"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "delete_virtual_machine" {
  name                = "Delete Virtual Machine"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.Compute/virtualMachines/delete events"

  criteria {
    operation_name = "Microsoft.Compute/virtualMachines/delete"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "power_off_virtual_machine" {
  name                = "Power Off Virtual Machine"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.Compute/virtualMachines/powerOff/action events"

  criteria {
    operation_name = "Microsoft.Compute/virtualMachines/powerOff/action"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "create_or_update_virtual_machine" {
  name                = "Create or Update Virtual Machine"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.Compute/virtualMachines/write events"

  criteria {
    operation_name = "Microsoft.Compute/virtualMachines/write"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "delete_mysql_database" {
  name                = "Delete MySQL Database"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.DBforMySQL/servers/databases/delete events"

  criteria {
    operation_name = "Microsoft.DBforMySQL/servers/databases/delete"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "create_or_update_mysql_database" {
  name                = "Create or Update MySQL Database"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.DBforMySQL/servers/databases/write events"

  criteria {
    operation_name = "Microsoft.DBforMySQL/servers/databases/write"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "delete_postgresql_database" {
  name                = "Delete PostgreSQL Database"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.DBforPostgreSQL/servers/databases/delete events"

  criteria {
    operation_name = "Microsoft.DBforPostgreSQL/servers/databases/delete"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "create_or_update_postgresql_database" {
  name                = "Create or Update PostgreSQL Database"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.DBforPostgreSQL/servers/databases/write events"

  criteria {
    operation_name = "Microsoft.DBforPostgreSQL/servers/databases/write"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "delete_key_vault" {
  name                = "Delete Key Vault"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.KeyVault/vaults/delete events"

  criteria {
    operation_name = "Microsoft.KeyVault/vaults/delete"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "update_key_vault" {
  name                = "Update Key Vault"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.KeyVault/vaults/write events"

  criteria {
    operation_name = "Microsoft.KeyVault/vaults/write"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "delete_load_balancer" {
  name                = "Delete Load Balancer"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.Network/loadBalancers/delete events"

  criteria {
    operation_name = "Microsoft.Network/loadBalancers/delete"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "create_or_update_load_balancer" {
  name                = "Create or Update Load Balancer"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.Network/loadBalancers/write events"

  criteria {
    operation_name = "Microsoft.Network/loadBalancers/write"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "delete_network_security_group" {
  name                = "Delete Network Security Group"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.Network/networkSecurityGroups/delete events"

  criteria {
    operation_name = "Microsoft.Network/networkSecurityGroups/delete"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "delete_network_security_group_rule" {
  name                = "Delete Network Security Group Rule"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.Network/networkSecurityGroups/securityRules/delete events"

  criteria {
    operation_name = "Microsoft.Network/networkSecurityGroups/securityRules/delete"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "create_or_update_network_security_group_rule" {
  name                = "Create or Update Network Security Group Rule"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.Network/networkSecurityGroups/securityRules/write events"

  criteria {
    operation_name = "Microsoft.Network/networkSecurityGroups/securityRules/write"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "create_or_update_network_security_group" {
  name                = "Create or Update Network Security Group"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.Network/networkSecurityGroups/write events"

  criteria {
    operation_name = "Microsoft.Network/networkSecurityGroups/write"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "create_or_update_security_policy" {
  name                = "Create or Update Security Policy"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.Security/policies/write events"

  criteria {
    operation_name = "Microsoft.Security/policies/write"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "delete_security_solution" {
  name                = "Delete Security Solution"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.Security/securitySolutions/delete events"

  criteria {
    operation_name = "Microsoft.Security/securitySolutions/delete"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "create_or_update_security_solution" {
  name                = "Create or Update Security Solution"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.Security/securitySolutions/write events"

  criteria {
    operation_name = "Microsoft.Security/securitySolutions/write"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "delete_azure_sql_database" {
  name                = "Delete Azure SQL Database"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.Sql/servers/databases/delete events"

  criteria {
    operation_name = "Microsoft.Sql/servers/databases/delete"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "rename_azure_sql_database" {
  name                = "Rename Azure SQL Database"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.Sql/servers/databases/move/action events"

  criteria {
    operation_name = "Microsoft.Sql/servers/databases/move/action"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "create_or_update_azure_sql_database" {
  name                = "Create or Update Azure SQL Database"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.Sql/servers/databases/write events"

  criteria {
    operation_name = "Microsoft.Sql/servers/databases/write"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "create_update_or_delete_sql_server_firewall_rule" {
  name                = "Create, Update or Delete SQL Server Firewall Rule"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.Sql/servers/firewallRules/write events"

  criteria {
    operation_name = "Microsoft.Sql/servers/firewallRules/write"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "delete_storage_account" {
  name                = "Delete Storage Account"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.Storage/storageAccounts/delete events"

  criteria {
    operation_name = "Microsoft.Storage/storageAccounts/delete"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "create_or_update_storage_account" {
  name                = "Create or Update Storage Account"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.Storage/storageAccounts/write events"

  criteria {
    operation_name = "Microsoft.Storage/storageAccounts/write"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "create_or_update_public_ip_address" {
  name                = "Create or Update Public IP Address"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.Network/publicIPAddresses/write events"

  criteria {
    operation_name = "Microsoft.Network/publicIPAddresses/write"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}

resource "azurerm_monitor_activity_log_alert" "delete_public_ip_address" {
  name                = "Delete Public IP Address"
  resource_group_name = azurerm_resource_group.monitor.name
  scopes              = [ "/subscriptions/${var.subscription_id}" ]
  description         = "This alert will monitor for Administrative:Microsoft.Network/publicIPAddresses/delete events"

  criteria {
    operation_name = "Microsoft.Network/publicIPAddresses/delete"
    category       = "Administrative"
  }

  action {
    action_group_id = azurerm_monitor_action_group.action.id
  }
}
