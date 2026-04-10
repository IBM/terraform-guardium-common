#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

output "reboot_required" {
  description = "Whether manual reboot is required to enable audit logging"
  value       = var.skip_reboot ? "Manual reboot required to enable audit logging" : "Audit logging enabled (reboot completed)"
}