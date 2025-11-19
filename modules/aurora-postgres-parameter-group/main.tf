#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

data "aws_rds_cluster" "cluster_metadata" {
  cluster_identifier = var.aurora_postgres_cluster_identifier
}

data "gdp-middleware-helper_aurora_postgres_parameter_group" "parameter_group" {
  cluster_identifier = var.aurora_postgres_cluster_identifier
  region = var.aws_region
}

locals {
  cluster_parameter_group_name = data.aws_rds_cluster.cluster_metadata.db_cluster_parameter_group_name
}

locals {
  family_name = lower(data.gdp-middleware-helper_aurora_postgres_parameter_group.parameter_group.family_name)
  default_pg_name = format("default.%s", local.family_name)
  is_default_pg = contains(
    [local.cluster_parameter_group_name],
    local.default_pg_name
  )
  parameter_group_name = local.is_default_pg ? format("guardium-aurora-postgres-param-group-%s", var.aurora_postgres_cluster_identifier) : local.cluster_parameter_group_name
  description = local.is_default_pg ? format("Custom parameter group for enabling audit for %s", var.aurora_postgres_cluster_identifier) : data.gdp-middleware-helper_aurora_postgres_parameter_group.parameter_group.description
}

resource "aws_rds_cluster_parameter_group" "guardium" {
  name        = local.parameter_group_name
  description = local.description
  family      = local.family_name

  # Add lifecycle configuration to create the new parameter group before destroying the old one
  lifecycle {
    create_before_destroy = true
  }

  parameter {
    name  = "pgaudit.log"
    value = var.pg_audit_log
  }

  parameter {
    name  = "pgaudit.log_catalog"
    value = "0"
  }

  parameter {
    name  = "pgaudit.log_parameter"
    value = "0"
  }

  # change here requires a reboot
  parameter {
    name         = "shared_preload_libraries"
    value        = "pgaudit"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "log_error_verbosity"
    value = "default"
  }

  dynamic "parameter" {
    for_each = var.pg_audit_role == "rds_pgaudit" ? [
      {
        name  = "pgaudit.role"
        value = var.pg_audit_role
      }
    ] : []

    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }
}

# we need to reboot the cluster here if the parameter group has changed.
resource "gdp-middleware-helper_aurora_reboot" "postgres_reboot" {
  depends_on = [aws_rds_cluster_parameter_group.guardium]

  cluster_identifier = var.aurora_postgres_cluster_identifier
  region = var.aws_region
  force_failover = var.force_failover
}