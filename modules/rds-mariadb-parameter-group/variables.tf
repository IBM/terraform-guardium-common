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

variable "mariadb_rds_cluster_identifier" {
  type        = string
  default     = "guardium-mariadb"
  description = "MariaDB RDS cluster identifier to be monitored"
}

variable "mariadb_major_version" {
  type        = string
  description = "The major version of MariaDB (e.g., '10.6')"
  default     = "10.6"
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
