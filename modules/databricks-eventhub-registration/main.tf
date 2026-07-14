#
# Copyright IBM Corp. 2025
# SPDX-License-Identifier: Apache-2.0
#

locals {
  # Create a sanitized version of the UDC name for file paths
  udc_name      = format("%s-%s", var.udc_name, var.azure_subscription_id)
  udc_name_safe = trimspace(replace(local.udc_name, "/", "-"))

  # Template args shared by both UC versions
  # UC 1.0 template args
  tpl_args_uc1 = {
    udc_name              = local.udc_name_safe
    description           = var.description
    credential_name       = var.udc_credential
    config_mode           = var.config_mode
    event_hub_connections = var.event_hub_connections
    initial_position      = var.csv_start_position
    threads               = var.threads
    decorate_events       = var.decorate_events
    consumer_group        = var.consumer_group
    enrollment_id         = var.azure_enrollment_id
    storage_connection    = var.storage_connection
  }

  # UC 2.0 template args
  tpl_args_uc2 = {
    udc_name                 = local.udc_name_safe
    description              = var.description
    credential_name          = var.udc_credential
    cluster_name             = var.cluster_name
    mu_count                 = var.mu_count
    use_elb                  = var.use_elb
    consumer_group           = var.consumer_group
    storage_connection       = var.storage_connection
    enrollment_id            = var.azure_enrollment_id
    eventhub_partition_count = var.eventhub_partition_count
    start_time               = var.start_time
    nodata_threshold_min     = var.nodata_threshold_min
  }

  # Select template by UC version — plugin name is hard-coded inside each template
  udc_csv = var.uc_version == "uc2" ? templatefile("${path.module}/templates/databricksUC2EventHub.tpl", local.tpl_args_uc2) : templatefile("${path.module}/templates/databricksEventHub.tpl", local.tpl_args_uc1)
}

module "universal_connector" {
  source = "IBM/gdp/guardium//modules/connect-datasource-to-uc"
  count  = var.enable_universal_connector ? 1 : 0 # Skip creation when disabled

  udc_name         = local.udc_name_safe
  udc_csv_parsed   = local.udc_csv
  test_connections = var.uc_version == "uc2" ? true : false

  client_id     = var.gdp_client_id
  client_secret = var.gdp_client_secret
  gdp_server    = var.gdp_server
  gdp_port      = var.gdp_port
  gdp_username  = var.gdp_username
  gdp_password  = var.gdp_password
  gdp_mu_host   = var.gdp_mu_host
}
