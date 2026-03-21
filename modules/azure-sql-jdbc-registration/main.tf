#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

locals {
  # Create a sanitized version of the UDC name for file paths
  udc_name      = format("%s-%s-%s", var.azure_region, var.udc_name, var.azure_subscription_id)
  udc_name_safe = trimspace(replace(local.udc_name, "/", "-"))

  # Generate the CSV content from the template
  udc_csv = templatefile("${path.module}/templates/azureSQLJDBC.tpl", {
    udc_name               = local.udc_name_safe
    description            = "GDP Azure SQL connector for ${var.udc_name}"
    jdbc_connection_string = var.jdbc_connection_string
    jdbc_user              = var.jdbc_user
    jdbc_password          = var.jdbc_password
    schedule               = var.schedule
    clean_run              = var.clean_run
    statement              = var.statement
    use_column_value       = var.use_column_value
    tracking_column        = var.tracking_column
    tracking_column_type   = var.tracking_column_type
    last_run_metadata_path = var.last_run_metadata_path
    enrollment_id          = var.enrollment_id
  })
}

module "universal_connector" {
  source = "IBM/gdp/guardium//modules/connect-datasource-to-uc"
  count  = var.enable_universal_connector ? 1 : 0 # Skip creation when disabled

  udc_name       = local.udc_name_safe
  udc_csv_parsed = local.udc_csv

  client_id     = var.gdp_client_id
  client_secret = var.gdp_client_secret
  gdp_server    = var.gdp_server
  gdp_port      = var.gdp_port
  gdp_username  = var.gdp_username
  gdp_password  = var.gdp_password
  gdp_mu_host   = var.gdp_mu_host
}