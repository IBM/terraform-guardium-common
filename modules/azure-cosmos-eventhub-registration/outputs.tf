#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

output "profile_csv" {
  description = "Universal Connector profile CSV content"
  value       = var.enable_universal_connector ? module.universal_connector[0].profile_csv : "Universal connector disabled"
}

output "udc_name" {
  description = "Name of the Universal Connector"
  value       = local.udc_name_safe
}