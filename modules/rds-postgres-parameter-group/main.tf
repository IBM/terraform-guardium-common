data "aws_db_instance" "cluster_metadata" {
  db_instance_identifier = var.postgres_rds_cluster_identifier
}

data "gdp-middleware-helper_rds_postgres_parameter_group" "paramater_group" {
  db_identifier =  var.postgres_rds_cluster_identifier
  region = var.aws_region
}

locals {
  instance_parameter_group_name = data.aws_db_instance.cluster_metadata.db_parameter_groups[0]
}

locals {
  family_name = lower(data.gdp-middleware-helper_rds_postgres_parameter_group.paramater_group.family_name)
  default_pg_name = format("default.%s", local.family_name)
  is_default_pg   = contains(
    [local.instance_parameter_group_name],
    local.default_pg_name
  )
  parameter_group_name = local.is_default_pg ? format("guardium-postgres-param-group-%s", var.postgres_rds_cluster_identifier) : local.instance_parameter_group_name
  description = local.is_default_pg ? format("Custom parameter group for enabling about for %s", var.postgres_rds_cluster_identifier) : data.gdp-middleware-helper_rds_postgres_parameter_group.paramater_group.description
}

resource "aws_db_parameter_group" "guardium" {
  name        = local.parameter_group_name
  description = local.description
  family      = local.family_name

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

# we need to reboot the instance here if the parameter group has changed.
resource "gdp-middleware-helper_rds_reboot" "postgres_reboot" {
  depends_on = [aws_db_parameter_group.guardium]

  db_instance_identifier = var.postgres_rds_cluster_identifier
  region = var.aws_region
  force_failover = var.force_failover
}
