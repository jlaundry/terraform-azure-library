
resource "azurerm_resource_group" "monitor" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_management_lock" "monitor-lock" {
  name       = "monitor-lock"
  scope      = azurerm_resource_group.monitor.id
  lock_level = "ReadOnly"
  notes      = "This Resource Group is Read Only"

  depends_on = [
    azurerm_monitor_action_group.action,

    azurerm_monitor_activity_log_alert.delete_resourcegroup_protection_alert,
    azurerm_monitor_activity_log_alert.write_resourcegroup_protection_alert,
    azurerm_monitor_activity_log_alert.delete_management_lock_protection_alert,
    azurerm_monitor_activity_log_alert.delete_actionGroups_protection_alert,
    azurerm_monitor_activity_log_alert.write_actionGroups_protection_alert,
    azurerm_monitor_activity_log_alert.delete_activitylog_protection_alert,
    azurerm_monitor_activity_log_alert.write_activitylog_protection_alert,

    azurerm_monitor_activity_log_alert.delete_policy_assignment,
    azurerm_monitor_activity_log_alert.create_or_update_policy_assignment,
    azurerm_monitor_activity_log_alert.deallocate_virtual_machine,
    azurerm_monitor_activity_log_alert.delete_virtual_machine,
    azurerm_monitor_activity_log_alert.power_off_virtual_machine,
    azurerm_monitor_activity_log_alert.create_or_update_virtual_machine,
    azurerm_monitor_activity_log_alert.delete_mysql_database,
    azurerm_monitor_activity_log_alert.create_or_update_mysql_database,
    azurerm_monitor_activity_log_alert.delete_postgresql_database,
    azurerm_monitor_activity_log_alert.create_or_update_postgresql_database,
    azurerm_monitor_activity_log_alert.delete_key_vault,
    azurerm_monitor_activity_log_alert.update_key_vault,
    azurerm_monitor_activity_log_alert.delete_load_balancer,
    azurerm_monitor_activity_log_alert.create_or_update_load_balancer,
    azurerm_monitor_activity_log_alert.delete_network_security_group,
    azurerm_monitor_activity_log_alert.delete_network_security_group_rule,
    azurerm_monitor_activity_log_alert.create_or_update_network_security_group_rule,
    azurerm_monitor_activity_log_alert.create_or_update_network_security_group,
    azurerm_monitor_activity_log_alert.create_or_update_security_policy,
    azurerm_monitor_activity_log_alert.delete_security_solution,
    azurerm_monitor_activity_log_alert.create_or_update_security_solution,
    azurerm_monitor_activity_log_alert.delete_azure_sql_database,
    azurerm_monitor_activity_log_alert.rename_azure_sql_database,
    azurerm_monitor_activity_log_alert.create_or_update_azure_sql_database,
    azurerm_monitor_activity_log_alert.create_update_or_delete_sql_server_firewall_rule,
    azurerm_monitor_activity_log_alert.delete_storage_account,
    azurerm_monitor_activity_log_alert.create_or_update_storage_account,
    azurerm_monitor_activity_log_alert.create_or_update_public_ip_address,
    azurerm_monitor_activity_log_alert.delete_public_ip_address,
  ]
}

resource "azurerm_monitor_action_group" "action" {
  name                = "actiongroup-admin"
  resource_group_name = azurerm_resource_group.monitor.name
  short_name          = "Admin Email"

  email_receiver {
    name                    = var.admin_email
    email_address           = var.admin_email
    use_common_alert_schema = true
  }
}
