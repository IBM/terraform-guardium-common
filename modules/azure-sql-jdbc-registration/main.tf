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
    credential_name        = var.credential_name
    enrollment_id          = var.enrollment_id
    jdbc_connection_string = var.jdbc_connection_string
    jdbc_driver_library    = var.jdbc_driver_library
    statement_select       = var.statement_select
    statement_from         = var.statement_from
    statement_where        = var.statement_where
    tracking_column_type   = var.tracking_column_type
    tracking_column        = var.tracking_column
    schedule               = var.schedule
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