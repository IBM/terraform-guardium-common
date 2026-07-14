#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

output "sql_server_id" {
  description = "ID of the SQL Server"
  value       = data.azurerm_mssql_server.sql_server.id
}

output "sql_server_fqdn" {
  description = "Fully qualified domain name of the SQL Server"
  value       = data.azurerm_mssql_server.sql_server.fully_qualified_domain_name
}

output "sql_database_id" {
  description = "ID of the SQL Database"
  value       = data.azurerm_mssql_database.sql_database.id
}

output "storage_account_endpoint" {
  description = "Primary blob endpoint of the Storage Account"
  value       = data.azurerm_storage_account.audit_logs.primary_blob_endpoint
}

output "server_audit_policy_id" {
  description = "ID of the server-level audit policy"
  value       = var.enable_server_audit ? azurerm_mssql_server_extended_auditing_policy.server_audit[0].id : null
}

output "database_audit_policy_id" {
  description = "ID of the database-level audit policy"
  value       = var.enable_database_audit ? azurerm_mssql_database_extended_auditing_policy.database_audit[0].id : null
}