#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

//////
// AWS variables
//////

variable "aws_region" {
  type        = string
  description = "This is the AWS region."
  default     = "us-east-1"
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to apply to resources"
  default     = {}
}

variable "db_engine" {
  type        = string
  description = "Database engine type (mysql or mariadb)"
  validation {
    condition     = contains(["mysql", "mariadb"], var.db_engine)
    error_message = "The db_engine value must be either 'mysql' or 'mariadb'."
  }
}

variable "rds_cluster_identifier" {
  type        = string
  description = "RDS cluster identifier to be monitored"
}

variable "db_major_version" {
  type        = string
  description = "The major version of the database (e.g., '5.7' for MySQL, '10.6' for MariaDB)"
}

//////
// Audit Plugin Configuration
//////

variable "audit_events" {
  type        = string
  description = "The events to audit (CONNECT,QUERY,TABLE,QUERY_DDL,QUERY_DML,QUERY_DCL)"
  default     = "CONNECT,QUERY,TABLE,QUERY_DDL,QUERY_DML,QUERY_DCL"
}

variable "audit_file_rotations" {
  type        = string
  description = "The number of audit file rotations to keep"
  default     = "10"
}

variable "audit_file_rotate_size" {
  type        = string
  description = "The size in bytes at which to rotate the audit log file"
  default     = "1000000"
}

variable "force_failover" {
  type        = bool
  default     = true
  description = "To failover the database instance, requires multi AZ databases. Results in minimal downtime"
}

variable "audit_incl_users" {
  type        = string
  description = "Comma-separated list of users to include in audit logs (SERVER_AUDIT_INCL_USERS). If set, only these users will be audited. Leave empty to audit all users."
  default     = ""
}

variable "audit_excl_users" {
  type        = string
  description = "Comma-separated list of users to exclude from audit logs (SERVER_AUDIT_EXCL_USERS). Example: 'rdsadmin,testuser'. The rdsadmin user queries the database every second for health checks, which can cause log files to grow quickly."
  default     = "rdsadmin"
}

variable "audit_query_log_limit" {
  type        = string
  description = "Maximum query length to log in bytes (SERVER_AUDIT_QUERY_LOG_LIMIT). Queries longer than this will be truncated. Default is 1024 bytes."
  default     = "1024"
}
