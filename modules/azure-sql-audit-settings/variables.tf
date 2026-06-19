#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

variable "sql_server_name" {
  description = "Name of the Azure SQL Server"
  type        = string
}

variable "sql_database_name" {
  description = "Name of the Azure SQL Database"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the Storage Account for audit logs"
  type        = string
}

variable "enable_server_audit" {
  description = "Enable server-level auditing"
  type        = bool
  default     = true
}

variable "enable_database_audit" {
  description = "Enable database-level auditing"
  type        = bool
  default     = true
}

variable "audit_retention_days" {
  description = "Number of days to retain audit logs"
  type        = number
  default     = 90
}

variable "log_monitoring_enabled" {
  description = "Enable log monitoring for audit logs"
  type        = bool
  default     = true
}