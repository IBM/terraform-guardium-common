#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

variable "cosmos_account_name" {
  description = "Name of the Azure Cosmos DB account"
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
  default     = "cosmos-audit-logs"
}

variable "enable_data_plane_logs" {
  description = "Enable DataPlaneRequests logs (CRUD operations)"
  type        = bool
  default     = true
}

variable "enable_query_runtime_logs" {
  description = "Enable QueryRuntimeStatistics logs"
  type        = bool
  default     = true
}

variable "enable_control_plane_logs" {
  description = "Enable ControlPlaneRequests logs (management operations)"
  type        = bool
  default     = false
}

variable "enable_partition_key_logs" {
  description = "Enable PartitionKeyStatistics logs"
  type        = bool
  default     = false
}

variable "enable_partition_ru_logs" {
  description = "Enable PartitionKeyRUConsumption logs"
  type        = bool
  default     = false
}