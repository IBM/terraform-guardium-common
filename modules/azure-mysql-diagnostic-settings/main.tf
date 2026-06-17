#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

data "azurerm_client_config" "current" {}

# Get MySQL Server details
data "azurerm_mysql_flexible_server" "mysql" {
  name                = var.mysql_server_name
  resource_group_name = var.resource_group_name
}

# Get Event Hub namespace details
data "azurerm_eventhub_namespace" "eventhub" {
  name                = var.eventhub_namespace_name
  resource_group_name = var.resource_group_name
}

# Get Event Hub details
data "azurerm_eventhub" "eventhub" {
  name                = var.eventhub_name
  namespace_name      = var.eventhub_namespace_name
  resource_group_name = var.resource_group_name
}

# Get Storage Account details (for Event Hub checkpointing)
data "azurerm_storage_account" "checkpoint" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

# Get Event Hub authorization rule
data "azurerm_eventhub_namespace_authorization_rule" "eventhub_auth" {
  name                = var.eventhub_authorization_rule_name
  namespace_name      = var.eventhub_namespace_name
  resource_group_name = var.resource_group_name
}

# Enable MySQL audit logging on the server
resource "azurerm_mysql_flexible_server_configuration" "audit_log_enabled" {
  name                = "audit_log_enabled"
  resource_group_name = var.resource_group_name
  server_name         = var.mysql_server_name
  value               = var.enable_mysql_audit_logs ? "ON" : "OFF"
}

# Configure audit log events
resource "azurerm_mysql_flexible_server_configuration" "audit_log_events" {
  count               = var.enable_mysql_audit_logs ? 1 : 0
  name                = "audit_log_events"
  resource_group_name = var.resource_group_name
  server_name         = var.mysql_server_name
  value               = var.audit_log_events
}

# Configure diagnostic settings to stream MySQL audit logs to Event Hub
resource "azurerm_monitor_diagnostic_setting" "mysql_audit" {
  name                           = var.diagnostic_setting_name
  target_resource_id             = data.azurerm_mysql_flexible_server.mysql.id
  eventhub_name                  = data.azurerm_eventhub.eventhub.name
  eventhub_authorization_rule_id = data.azurerm_eventhub_namespace_authorization_rule.eventhub_auth.id
  storage_account_id             = data.azurerm_storage_account.checkpoint.id

  # Enable MySQL Audit logs
  dynamic "enabled_log" {
    for_each = var.enable_mysql_audit_logs ? [1] : []
    content {
      category = "MySqlAuditLogs"
    }
  }

  # Enable MySQL Slow Query logs
  dynamic "enabled_log" {
    for_each = var.enable_slow_query_logs ? [1] : []
    content {
      category = "MySqlSlowLogs"
    }
  }

  depends_on = [
    data.azurerm_mysql_flexible_server.mysql,
    data.azurerm_eventhub.eventhub,
    data.azurerm_eventhub_namespace_authorization_rule.eventhub_auth,
    data.azurerm_storage_account.checkpoint,
    azurerm_mysql_flexible_server_configuration.audit_log_enabled,
    azurerm_mysql_flexible_server_configuration.audit_log_events
  ]
}