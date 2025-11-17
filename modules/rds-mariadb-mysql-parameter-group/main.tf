#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

data "aws_db_instance" "cluster_metadata" {
  db_instance_identifier = var.rds_cluster_identifier
}

# Use the appropriate data source based on the engine type
data "gdp-middleware-helper_rds_mariadb" "mariadb_parameter_group" {
  count = var.db_engine == "mariadb" ? 1 : 0
  db_identifier = var.rds_cluster_identifier
  region = var.aws_region
}

data "gdp-middleware-helper_rds_mysql" "mysql_parameter_group" {
  count = var.db_engine == "mysql" ? 1 : 0
  db_identifier = var.rds_cluster_identifier
  region = var.aws_region
}

locals {
  instance_parameter_group_name = data.aws_db_instance.cluster_metadata.db_parameter_groups[0]

  # Set values based on engine type
  family_name = var.db_engine == "mariadb" ? (
    length(data.gdp-middleware-helper_rds_mariadb.mariadb_parameter_group) > 0 ?
    data.gdp-middleware-helper_rds_mariadb.mariadb_parameter_group[0].family_name : ""
  ) : (
    length(data.gdp-middleware-helper_rds_mysql.mysql_parameter_group) > 0 ?
    data.gdp-middleware-helper_rds_mysql.mysql_parameter_group[0].family_name : ""
  )

  default_pg_name = format("default.%s", local.family_name)
  is_default_pg   = contains([local.instance_parameter_group_name], local.default_pg_name)

  parameter_group_name = local.is_default_pg ? format("guardium-%s-param-group-%s", var.db_engine, var.rds_cluster_identifier) : local.instance_parameter_group_name

  # Use a custom description that includes the engine type
  description = format("Custom parameter group for enabling %s audit for %s", var.db_engine, var.rds_cluster_identifier)

  # Get option group details based on engine type
  option_group = var.db_engine == "mariadb" ? (
    length(data.gdp-middleware-helper_rds_mariadb.mariadb_parameter_group) > 0 ?
    data.gdp-middleware-helper_rds_mariadb.mariadb_parameter_group[0].option_group : ""
  ) : (
    length(data.gdp-middleware-helper_rds_mysql.mysql_parameter_group) > 0 ?
    data.gdp-middleware-helper_rds_mysql.mysql_parameter_group[0].option_group : ""
  )

  engine_name = var.db_engine == "mariadb" ? (
    length(data.gdp-middleware-helper_rds_mariadb.mariadb_parameter_group) > 0 ?
    data.gdp-middleware-helper_rds_mariadb.mariadb_parameter_group[0].engine_name : ""
  ) : (
    length(data.gdp-middleware-helper_rds_mysql.mysql_parameter_group) > 0 ?
    data.gdp-middleware-helper_rds_mysql.mysql_parameter_group[0].engine_name : ""
  )

  major_version = var.db_engine == "mariadb" ? (
    length(data.gdp-middleware-helper_rds_mariadb.mariadb_parameter_group) > 0 ?
    data.gdp-middleware-helper_rds_mariadb.mariadb_parameter_group[0].major_version : ""
  ) : (
    length(data.gdp-middleware-helper_rds_mysql.mysql_parameter_group) > 0 ?
    data.gdp-middleware-helper_rds_mysql.mysql_parameter_group[0].major_version : ""
  )

  # Use MariaDB audit plugin for both MariaDB and MySQL
  audit_plugin = "MARIADB_AUDIT_PLUGIN"
}

# Create a custom parameter group if using the default one
resource "aws_db_parameter_group" "db_param_group" {
  name   = local.parameter_group_name
  family = local.family_name
  description = local.description

  parameter {
    name  = "log_output"
    value = "FILE"
    apply_method = "pending-reboot"
  }

  lifecycle {
    ignore_changes = [
      description,  # Ignore description changes to prevent replacement
      tags,                      # Ignore tag changes
      tags_all                   # Ignore tags_all changes
    ]
  }

  tags = var.tags
}

# Modify existing option group with audit plugin
resource "aws_db_option_group" "audit" {
  name                     = local.option_group
  option_group_description = format("Option group with %s audit plugin for %s", var.db_engine, var.rds_cluster_identifier)
  engine_name              = local.engine_name
  major_engine_version     = local.major_version

  option {
    option_name = local.audit_plugin

    option_settings {
      name  = "SERVER_AUDIT_EVENTS"
      value = var.audit_events
    }

    option_settings {
      name  = "SERVER_AUDIT_FILE_ROTATIONS"
      value = var.audit_file_rotations
    }

    option_settings {
      name  = "SERVER_AUDIT_FILE_ROTATE_SIZE"
      value = var.audit_file_rotate_size
    }

    dynamic "option_settings" {
      for_each = var.audit_incl_users != "" ? [1] : []
      content {
        name  = "SERVER_AUDIT_INCL_USERS"
        value = var.audit_incl_users
      }
    }

    dynamic "option_settings" {
      for_each = var.audit_excl_users != "" ? [1] : []
      content {
        name  = "SERVER_AUDIT_EXCL_USERS"
        value = var.audit_excl_users
      }
    }

    option_settings {
      name  = "SERVER_AUDIT_QUERY_LOG_LIMIT"
      value = var.audit_query_log_limit
    }
  }

  lifecycle {
    ignore_changes = [
      option_group_description,  # Ignore description changes to prevent replacement
      tags,                      # Ignore tag changes
      tags_all                   # Ignore tags_all changes
    ]
  }

  tags = var.tags
}

# Use the GDP middleware helper to modify the instance and enable CloudWatch log exports
resource "gdp-middleware-helper_rds_modify" "enable_audit_logs" {
  depends_on = [
    aws_db_parameter_group.db_param_group,
    aws_db_option_group.audit,
  ]

  db_instance_identifier   = var.rds_cluster_identifier
  region                   = var.aws_region
  parameter_group_name     = aws_db_parameter_group.db_param_group.name
  option_group_name        = aws_db_option_group.audit.name
  cloudwatch_logs_exports  = ["audit"]
  apply_immediately        = true
}

# Use the GDP middleware helper to reboot the instance
resource "gdp-middleware-helper_rds_reboot" "db_reboot" {
  depends_on = [
    gdp-middleware-helper_rds_modify.enable_audit_logs,
  ]

  db_instance_identifier = var.rds_cluster_identifier
  region = var.aws_region
  force_failover = var.force_failover
}
