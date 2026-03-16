#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

data "azurerm_client_config" "current" {}

# Get Cosmos DB account details
data "azurerm_cosmosdb_account" "cosmos" {
  name                = var.cosmos_account_name
  resource_group_name = var.resource_group_name
}

# Get Event Hub namespace details
data "azurerm_eventhub_namespace" "eventhub" {
  name                = var.eventhub_namespace_name
  resource_group_name = var.resource_group_name
}

# Get Event Hub details
data "azurerm_eventhub" "eventhub" {
  name                = var.eventhub_name
  namespace_name      = var.eventhub_namespace_name
  resource_group_name = var.resource_group_name
}

# Get Storage Account details (for Event Hub checkpointing)
data "azurerm_storage_account" "checkpoint" {
  name                = var.storage_account_name
  resource_group_name = var.resource_group_name
}

# Get Event Hub authorization rule
data "azurerm_eventhub_namespace_authorization_rule" "eventhub_auth" {
  name                = var.eventhub_authorization_rule_name
  namespace_name      = var.eventhub_namespace_name
  resource_group_name = var.resource_group_name
}

# Configure diagnostic settings to stream Cosmos DB audit logs to Event Hub
resource "azurerm_monitor_diagnostic_setting" "cosmos_audit" {
  name                           = var.diagnostic_setting_name
  target_resource_id             = data.azurerm_cosmosdb_account.cosmos.id
  eventhub_name                  = data.azurerm_eventhub.eventhub.name
  eventhub_authorization_rule_id = data.azurerm_eventhub_namespace_authorization_rule.eventhub_auth.id
  storage_account_id             = data.azurerm_storage_account.checkpoint.id

  # Enable DataPlaneRequests logs (CRUD operations)
  dynamic "enabled_log" {
    for_each = var.enable_data_plane_logs ? [1] : []
    content {
      category = "DataPlaneRequests"
    }
  }

  # Enable QueryRuntimeStatistics logs
  dynamic "enabled_log" {
    for_each = var.enable_query_runtime_logs ? [1] : []
    content {
      category = "QueryRuntimeStatistics"
    }
  }

  # Enable ControlPlaneRequests logs (management operations)
  dynamic "enabled_log" {
    for_each = var.enable_control_plane_logs ? [1] : []
    content {
      category = "ControlPlaneRequests"
    }
  }

  # Enable PartitionKeyStatistics logs
  dynamic "enabled_log" {
    for_each = var.enable_partition_key_logs ? [1] : []
    content {
      category = "PartitionKeyStatistics"
    }
  }

  # Enable PartitionKeyRUConsumption logs
  dynamic "enabled_log" {
    for_each = var.enable_partition_ru_logs ? [1] : []
    content {
      category = "PartitionKeyRUConsumption"
    }
  }

  # Enable metrics
  metric {
    category = "Requests"
    enabled  = true
  }

  depends_on = [
    data.azurerm_cosmosdb_account.cosmos,
    data.azurerm_eventhub.eventhub,
    data.azurerm_eventhub_namespace_authorization_rule.eventhub_auth,
    data.azurerm_storage_account.checkpoint
  ]
}