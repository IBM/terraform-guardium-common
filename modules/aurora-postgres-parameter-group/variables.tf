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
}

variable "tags" {
  type        = map(string)
  description = "Map of tags to apply to resources"
  default     = {}
}

variable "aurora_postgres_cluster_identifier" {
  type        = string
  description = "Aurora PostgreSQL cluster identifier to be monitored"
}

variable "force_failover" {
  type        = bool
  default = false
  description = "To failover the database cluster, requires multi AZ databases. Results in minimal downtime"
}


variable "pg_audit_log" {
  description = "The parameter group audit log value for postgres"
}

variable "pg_audit_role" {
  description = "The parameter group role log value for postgres"
}

variable "parameter_group_family" {
  type        = string
  description = "The family of the Aurora PostgreSQL parameter group"
  default     = "aurora-postgresql14"
}