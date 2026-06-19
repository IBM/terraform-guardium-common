#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

data "azurerm_client_config" "current" {}

# Get SQL Server details
data "azurerm_mssql_server" "sql_server" {
  name                = var.sql_server_name
  resource_group_name = var.resource_group_name
}

# Get SQL Database details
data "azurerm_mssql_database" "sql_database" {
  name      = var.sql_database_name
  server_id = data.azurerm_mssql_server.sql_server.id
}

# Get Storage Account details (for audit logs)
data "azurerm_storage_account" "audit_logs" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

# Configure Server-Level Auditing
resource "azurerm_mssql_server_extended_auditing_policy" "server_audit" {
  count                                   = var.enable_server_audit ? 1 : 0
  server_id                               = data.azurerm_mssql_server.sql_server.id
  storage_endpoint                        = data.azurerm_storage_account.audit_logs.primary_blob_endpoint
  storage_account_access_key              = data.azurerm_storage_account.audit_logs.primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = var.audit_retention_days
  log_monitoring_enabled                  = var.log_monitoring_enabled
}

# Configure Database-Level Auditing
resource "azurerm_mssql_database_extended_auditing_policy" "database_audit" {
  count                                   = var.enable_database_audit ? 1 : 0
  database_id                             = data.azurerm_mssql_database.sql_database.id
  storage_endpoint                        = data.azurerm_storage_account.audit_logs.primary_blob_endpoint
  storage_account_access_key              = data.azurerm_storage_account.audit_logs.primary_access_key
  storage_account_access_key_is_secondary = false
  retention_in_days                       = var.audit_retention_days
  log_monitoring_enabled                  = var.log_monitoring_enabled
}