#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

//////
// Azure variables
//////

variable "azure_region" {
  type        = string
  description = "Azure region where the resource is located"
}

variable "azure_subscription_id" {
  type        = string
  description = "Azure subscription ID, used to generate the universal connector name"
}

variable "azure_enrollment_id" {
  type        = string
  description = "Azure Enrollment ID (required)"
}

//////
// General variables
//////

variable "uc_version" {
  type        = string
  description = "Databricks UC version: 'uc1' uses the 'Azure Databricks Over Event Hub' plugin, 'uc2' uses 'Azure Databricks Over Event Hub Connect 2.0'"
  default     = "uc1"

  validation {
    condition     = contains(["uc1", "uc2"], var.uc_version)
    error_message = "uc_version must be either 'uc1' or 'uc2'."
  }
}

variable "udc_name" {
  type        = string
  description = "Name for the universal connector. Used to uniquely identify the UC profile in Guardium"
}

variable "description" {
  type        = string
  description = "Description for the Universal Connector profile"
  default     = ""
}

variable "gdp_client_secret" {
  type        = string
  description = "Client secret from output of grdapi register_oauth_client"
  sensitive   = true
}

variable "gdp_client_id" {
  type        = string
  description = "Client id used when running grdapi register_oauth_client"
}

variable "gdp_server" {
  type        = string
  description = "Hostname/IP address of Guardium Central Manager"
}

variable "gdp_port" {
  type        = string
  description = "Port of Guardium Central Manager"
  default     = "8443"
}

variable "gdp_username" {
  type        = string
  description = "Username of Guardium Web UI user"
}

variable "gdp_password" {
  type        = string
  description = "Password of Guardium Web UI user"
  sensitive   = true
}

variable "gdp_mu_host" {
  type        = string
  description = "Comma separated list of Guardium Managed Units to deploy profile"
}

//////
// Universal Connector Control
//////

variable "enable_universal_connector" {
  type        = bool
  description = "Whether to enable the universal connector module. Set to false to completely disable the universal connector for a run."
  default     = true
}

variable "csv_start_position" {
  type        = string
  description = "Start position for UDC (beginning, end)"
  default     = "end"
}

//////
// Azure Event Hub Configuration
//////

variable "config_mode" {
  type        = string
  description = "Configuration mode for Event Hub input (basic or advanced)"
  default     = "basic"
}

variable "event_hub_connections" {
  type        = string
  description = "Event Hub connection string (Endpoint=sb://...)"
  sensitive   = true
}

variable "threads" {
  type        = number
  description = "Number of threads for Event Hub consumer"
  default     = 8
}

variable "decorate_events" {
  type        = bool
  description = "Whether to decorate events with Event Hub metadata"
  default     = true
}

variable "consumer_group" {
  type        = string
  description = "Event Hub consumer group name"
  default     = "$Default"
}

variable "storage_connection" {
  type        = string
  description = "Azure Storage connection string for Event Hub checkpointing"
  sensitive   = true
}

variable "cluster_name" {
  type        = string
  description = "Guardium cluster name (UC 2.0 only)"
  default     = ""
}

variable "udc_credential" {
  type        = string
  description = "Name of the credential configured in Guardium CM for this Universal Connector"
  default     = ""
}

variable "mu_count" {
  type        = number
  description = "Number of Managed Units to deploy the profile to (UC 2.0)"
  default     = 2
}

variable "use_elb" {
  type        = bool
  description = "Whether to use ELB (UC 2.0)"
  default     = false
}

variable "eventhub_partition_count" {
  type        = number
  description = "Number of Event Hub partitions (UC 2.0)"
  default     = 4
}

variable "start_time" {
  type        = number
  description = "Start time as epoch in milliseconds (UC 2.0, 0 = disabled)"
  default     = 0
}

variable "nodata_threshold_min" {
  type        = number
  description = "No data threshold in minutes (UC 2.0)"
  default     = 60
}
