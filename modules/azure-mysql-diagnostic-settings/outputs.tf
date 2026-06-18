#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

output "mysql_server_endpoint" {
  description = "Fully qualified domain name of the MySQL server"
  value       = data.azurerm_mysql_flexible_server.mysql.fqdn
}

output "diagnostic_setting_name" {
  description = "Name of the diagnostic setting"
  value       = azurerm_monitor_diagnostic_setting.mysql_audit.name
}

output "diagnostic_setting_id" {
  description = "ID of the diagnostic setting"
  value       = azurerm_monitor_diagnostic_setting.mysql_audit.id
}