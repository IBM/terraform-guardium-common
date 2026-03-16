#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

output "cosmos_account_endpoint" {
  description = "Endpoint of the Cosmos DB account"
  value       = data.azurerm_cosmosdb_account.cosmos.endpoint
}

output "diagnostic_setting_name" {
  description = "Name of the diagnostic setting"
  value       = azurerm_monitor_diagnostic_setting.cosmos_audit.name
}

output "diagnostic_setting_id" {
  description = "ID of the diagnostic setting"
  value       = azurerm_monitor_diagnostic_setting.cosmos_audit.id
}