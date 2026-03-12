#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

locals {
  # Create a sanitized version of the UDC name for file paths
  udc_name = format("%s-%s-%s", var.aws_region, var.udc_name, var.aws_account_id)
  udc_name_safe = trimspace(replace(local.udc_name, "/", "-"))

  # Generate the CSV content from the template with proper quoting for empty fields
  udc_csv = templatefile("${path.module}/templates/auroraMySqlCloudwatch.tpl", {
    udc_name            = local.udc_name_safe
    credential_name     = var.udc_aws_credential
    aws_region          = var.aws_region
    aws_log_group       = var.log_group
    aws_account_id      = var.aws_account_id
    prefix              = var.prefix
    unmask              = var.unmask
    start_position      = var.csv_start_position
    interval            = var.csv_interval
    event_filter        = var.csv_event_filter
    description         = "GDP AWS Aurora MySQL connector for ${var.udc_name}"
    cloudwatch_endpoint = var.cloudwatch_endpoint
    use_aws_bundled_ca  = var.use_aws_bundled_ca
  })
}

module "universal_connector" {
  source = "IBM/gdp/guardium//modules/connect-datasource-to-uc"
  count  = var.enable_universal_connector ? 1 : 0  # Skip creation when disabled

  udc_name       = local.udc_name_safe
  udc_csv_parsed = local.udc_csv

  client_id              = var.gdp_client_id
  client_secret          = var.gdp_client_secret
  gdp_server             = var.gdp_server
  gdp_port               = var.gdp_port
  gdp_username           = var.gdp_username
  gdp_password           = var.gdp_password
  gdp_mu_host            = var.gdp_mu_host
}
