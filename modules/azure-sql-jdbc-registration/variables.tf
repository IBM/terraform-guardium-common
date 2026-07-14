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

variable "credential_name" {
  type        = string
  description = "Name of the JDBC credential configured in Guardium CM"
  default     = "azure-sql-jdbc-cred"
}

variable "jdbc_driver_library" {
  type        = string
  description = "Name of the JDBC driver JAR file uploaded to Guardium CM"
  default     = "mssql-jdbc-7.4.1.jre8.jar"
}

variable "statement_select" {
  type        = string
  description = "SELECT clause for the SQL query"
}

variable "statement_from" {
  type        = string
  description = "FROM clause for the SQL query (sys.fn_get_audit_file)"
}

variable "statement_where" {
  type        = string
  description = "WHERE clause for the SQL query with filters"
}

variable "schedule" {
  type        = string
  description = "Cron schedule for JDBC polling (e.g., '*/1 * * * *' for every minute)"
  default     = "*/1 * * * *"
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

variable "enrollment_id" {
  type        = string
  description = "Azure enrollment ID for the account"
  default     = "123456789"
}