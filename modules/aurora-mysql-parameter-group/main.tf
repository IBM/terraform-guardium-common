#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

data "aws_rds_cluster" "cluster_metadata" {
  cluster_identifier = var.aurora_mysql_cluster_identifier
}

data "aws_rds_cluster_parameter_group" "existing" {
  count = data.aws_rds_cluster.cluster_metadata.db_cluster_parameter_group_name != null ? 1 : 0
  name  = data.aws_rds_cluster.cluster_metadata.db_cluster_parameter_group_name
}

locals {
  cluster_parameter_group_name = data.aws_rds_cluster.cluster_metadata.db_cluster_parameter_group_name
  engine_version = data.aws_rds_cluster.cluster_metadata.engine_version
  
  # Extract major version from engine version (e.g., "8.0.mysql_aurora.3.04.0" -> "8.0")
  major_version = split(".", local.engine_version)[0]
  minor_version = split(".", local.engine_version)[1]
  family_name = format("aurora-mysql%s.%s", local.major_version, local.minor_version)
  
  default_pg_name = format("default.%s", local.family_name)
  is_default_pg = contains(
    [local.cluster_parameter_group_name],
    local.default_pg_name
  )
  parameter_group_name = local.is_default_pg ? format("guardium-aurora-mysql-param-group-%s", var.aurora_mysql_cluster_identifier) : local.cluster_parameter_group_name
  description = local.is_default_pg ? format("Custom parameter group for enabling audit for %s", var.aurora_mysql_cluster_identifier) : (
    length(data.aws_rds_cluster_parameter_group.existing) > 0 ? data.aws_rds_cluster_parameter_group.existing[0].description : "Custom parameter group"
  )
}

# Create a custom cluster parameter group
# This will update the existing parameter group if it already exists with the same name
resource "aws_rds_cluster_parameter_group" "aurora_mysql_param_group" {
  name        = local.parameter_group_name
  description = local.description
  family      = local.family_name

  # Enable server audit logging for Aurora MySQL
  parameter {
    name  = "server_audit_logging"
    value = "1"
  }

  # Set audit events
  parameter {
    name  = "server_audit_events"
    value = var.audit_events
  }

  # Include users (if specified)
  dynamic "parameter" {
    for_each = var.audit_incl_users != "" ? [1] : []
    content {
      name  = "server_audit_incl_users"
      value = var.audit_incl_users
    }
  }

  # Exclude users (if specified)
  dynamic "parameter" {
    for_each = var.audit_excl_users != "" ? [1] : []
    content {
      name  = "server_audit_excl_users"
      value = var.audit_excl_users
    }
  }

  lifecycle {
    create_before_destroy = true
    # Ignore changes to prevent recreation when parameter group already exists
    ignore_changes = [
      description
    ]
  }

  tags = var.tags
}

# Use the GDP middleware helper to modify the cluster and enable CloudWatch log exports
resource "gdp-middleware-helper_aurora_modify" "enable_audit_logs" {
  depends_on = [
    aws_rds_cluster_parameter_group.aurora_mysql_param_group,
  ]

  cluster_identifier      = var.aurora_mysql_cluster_identifier
  region                  = var.aws_region
  parameter_group_name    = aws_rds_cluster_parameter_group.aurora_mysql_param_group.name
  cloudwatch_logs_exports = var.cloudwatch_logs_exports
  apply_immediately       = true
}

# Use the GDP middleware helper to reboot the cluster
resource "gdp-middleware-helper_aurora_reboot" "mysql_reboot" {
  depends_on = [
    gdp-middleware-helper_aurora_modify.enable_audit_logs,
  ]

  cluster_identifier = var.aurora_mysql_cluster_identifier
  region = var.aws_region
  force_failover = var.force_failover
}