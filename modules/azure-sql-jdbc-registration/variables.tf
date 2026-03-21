#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

//////
// Azure variables
//////

variable "azure_region" {
  type        = string
  description = "Azure region where the SQL Server is located"
}

variable "azure_subscription_id" {
  type        = string
  description = "Azure subscription ID, used to generate the universal connector name"
}

//////
// General variables
//////

variable "udc_name" {
  type        = string
  description = "Name for universal connector. Is used for all Azure objects"
  default     = "azure-sql-gdp"
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

//////
// Azure SQL JDBC Configuration
//////

variable "jdbc_connection_string" {
  type        = string
  description = "JDBC connection string for Azure SQL Database"
}

variable "jdbc_user" {
  type        = string
  description = "JDBC username in format: user@server_instance_name"
}

variable "jdbc_password" {
  type        = string
  description = "JDBC password for Azure SQL Database"
  sensitive   = true
}

variable "schedule" {
  type        = string
  description = "Cron schedule for JDBC polling (e.g., '*/1 * * * *' for every minute)"
  default     = "*/1 * * * *"
}

variable "clean_run" {
  type        = bool
  description = "Whether to start from the beginning on each run"
  default     = false
}

variable "statement" {
  type        = string
  description = "SQL statement to query audit logs from sys.fn_get_audit_file()"
}

variable "use_column_value" {
  type        = bool
  description = "Whether to use column value for tracking"
  default     = true
}

variable "tracking_column" {
  type        = string
  description = "Column name to track for incremental reads"
  default     = "updatedeventtime"
}

variable "tracking_column_type" {
  type        = string
  description = "Data type of the tracking column"
  default     = "numeric"
}

variable "last_run_metadata_path" {
  type        = string
  description = "Path to store the last run metadata"
  default     = "./.azureSQL_logstash_jdbc_last_run"
}

variable "enrollment_id" {
  type        = string
  description = "Azure enrollment ID for the account"
}