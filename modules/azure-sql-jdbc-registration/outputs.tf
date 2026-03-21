#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

output "udc_name" {
  description = "Name of the Universal Connector"
  value       = local.udc_name_safe
}

output "udc_csv" {
  description = "Generated CSV configuration for the Universal Connector"
  value       = local.udc_csv
  sensitive   = true
}

output "profile_csv" {
  description = "Universal Connector profile CSV content (alias for udc_csv)"
  value       = var.enable_universal_connector ? module.universal_connector[0].profile_csv : "Universal connector disabled"
  sensitive   = true
}

output "connector_enabled" {
  description = "Whether the Universal Connector is enabled"
  value       = var.enable_universal_connector
}