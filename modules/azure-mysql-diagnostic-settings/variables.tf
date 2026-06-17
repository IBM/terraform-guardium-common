#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

variable "mysql_server_name" {
  description = "Name of the Azure MySQL Flexible Server"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
}

variable "eventhub_namespace_name" {
  description = "Name of the Event Hub namespace"
  type        = string
}

variable "eventhub_name" {
  description = "Name of the Event Hub"
  type        = string
}

variable "storage_account_name" {
  description = "Name of the Storage Account for Event Hub checkpointing"
  type        = string
}

variable "eventhub_authorization_rule_name" {
  description = "Name of the Event Hub authorization rule"
  type        = string
}

variable "diagnostic_setting_name" {
  description = "Name of the diagnostic setting"
  type        = string
  default     = "mysql-audit-logs"
}

variable "enable_mysql_audit_logs" {
  description = "Enable MySQL Audit logs"
  type        = bool
  default     = true
}

variable "enable_slow_query_logs" {
  description = "Enable MySQL Slow Query logs"
  type        = bool
  default     = false
}

variable "audit_log_events" {
  description = "MySQL audit log events to capture. Options: CONNECTION (connection events), GENERAL (DML_SELECT, DML_NONSELECT, DML, DDL, DCL, ADMIN)"
  type        = string
  default     = "CONNECTION,GENERAL"
}