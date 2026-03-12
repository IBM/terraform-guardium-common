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

variable "aurora_mysql_cluster_identifier" {
  type        = string
  description = "Aurora MySQL cluster identifier to be monitored"
}

variable "force_failover" {
  type        = bool
  default     = false
  description = "To failover the database cluster, requires multi AZ databases. Results in minimal downtime"
}

//////
// Audit Plugin Configuration
//////

variable "audit_events" {
  type        = string
  description = "Comma-separated list of events to audit (CONNECT,QUERY,TABLE,QUERY_DDL,QUERY_DML,QUERY_DCL)"
  default     = "CONNECT,QUERY"
}

variable "audit_incl_users" {
  type        = string
  description = "Comma-separated list of users to include in audit logs (server_audit_incl_users). If set, only these users will be audited. Leave empty to audit all users."
  default     = ""
}

variable "audit_excl_users" {
  type        = string
  description = "Comma-separated list of users to exclude from audit logs (server_audit_excl_users). Example: 'rdsadmin,testuser'. The rdsadmin user queries the database every second for health checks, which can cause log files to grow quickly."
  default     = "rdsadmin"
}

variable "cloudwatch_logs_exports" {
  type        = list(string)
  description = "List of log types to export to CloudWatch. Valid values for Aurora MySQL: audit, error, general, slowquery"
  default     = ["audit"]
}