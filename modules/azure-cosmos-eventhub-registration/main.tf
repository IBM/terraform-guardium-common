#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

locals {
  # Create a sanitized version of the UDC name for file paths
  udc_name      = format("%s-%s-%s", var.azure_region, var.udc_name, var.azure_subscription_id)
  udc_name_safe = trimspace(replace(local.udc_name, "/", "-"))

  # Generate the CSV content from the template
  udc_csv = templatefile("${path.module}/templates/azureCosmosEventHub.tpl", {
    udc_name              = local.udc_name_safe
    description           = "GDP Azure Cosmos DB connector for ${var.udc_name}"
    config_mode           = var.config_mode
    event_hub_connections = var.event_hub_connections
    initial_position      = var.csv_start_position
    threads               = var.threads
    decorate_events       = var.decorate_events
    consumer_group        = var.consumer_group
    storage_connection    = var.storage_connection
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