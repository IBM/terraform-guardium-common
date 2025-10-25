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

variable "postgres_rds_cluster_identifier" {
  type        = string
  description = "DocumentDB cluster identifier to be monitored"
}

variable "force_failover" {
  type        = bool
  default = true
  description = "To failover the database instance, requires multi AZ databases. Results in minimal downtime"
}


variable "pg_audit_log" {
  description = "The parameter group audit log value for postgres"
}

variable "pg_audit_role" {
  description = "The parameter group role log value for postgres"
}