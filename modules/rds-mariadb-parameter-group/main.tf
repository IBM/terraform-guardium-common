data "aws_db_instance" "cluster_metadata" {
  db_instance_identifier = var.mariadb_rds_cluster_identifier
}

data "gdp-middleware-helper_rds_mariadb" "parameter_group" {
  db_identifier = var.mariadb_rds_cluster_identifier
  region = var.aws_region
}

locals {
  instance_parameter_group_name = data.aws_db_instance.cluster_metadata.db_parameter_groups[0]
}

locals {
  family_name = data.gdp-middleware-helper_rds_mariadb.parameter_group.family_name
  default_pg_name = format("default.%s", local.family_name)
  is_default_pg   = contains(
    [local.instance_parameter_group_name],
    local.default_pg_name
  )
  parameter_group_name = local.is_default_pg ? format("guardium-mariadb-param-group-%s", var.mariadb_rds_cluster_identifier) : local.instance_parameter_group_name
  description = local.is_default_pg ? format("Custom parameter group for enabling audit for %s", var.mariadb_rds_cluster_identifier) : data.gdp-middleware-helper_rds_mariadb.parameter_group.parameter_group_description
}

resource "aws_db_parameter_group" "mariadb_param_group" {
  name   = local.parameter_group_name
  family = local.family_name
  description = local.description

  parameter {
    name  = "log_output"
    value = "FILE"
    apply_method = "pending-reboot"
  }

  tags = var.tags
}

# Modify existing option group with audit plugin
resource "aws_db_option_group" "audit" {
  name                     = data.gdp-middleware-helper_rds_mariadb.parameter_group.option_group
  option_group_description = format("Option group with MariaDB audit plugin for %s", var.mariadb_rds_cluster_identifier)
  engine_name              = data.gdp-middleware-helper_rds_mariadb.parameter_group.engine_name
  major_engine_version     = data.gdp-middleware-helper_rds_mariadb.parameter_group.major_version

  option {
    option_name = "MARIADB_AUDIT_PLUGIN"

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

    option_settings {
      name  = "SERVER_AUDIT_EXCL_USERS"
      value = "rdsadmin"
    }
  }

  lifecycle {
    create_before_destroy = true
    # This is important to prevent Terraform from trying to create a new resource
    # when the option group already exists
    ignore_changes = [option_group_description]
  }

  tags = var.tags
}

# Use the GDP middleware helper to reboot the instance
resource "gdp-middleware-helper_rds_reboot" "mariadb_reboot" {
  depends_on = [
    aws_db_parameter_group.mariadb_param_group,
    aws_db_option_group.audit,
  ]

  db_instance_identifier = var.mariadb_rds_cluster_identifier
  region = var.aws_region
  force_failover = var.force_failover
}
