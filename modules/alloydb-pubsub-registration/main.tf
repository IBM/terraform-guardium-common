#
# Copyright IBM Corp. 2026
# SPDX-License-Identifier: Apache-2.0
#

locals {
  # Create a sanitized version of the UDC name for file paths
  udc_name      = format("%s-%s-%s", var.gcp_region, var.udc_name, var.gcp_project_id)
  udc_name_safe = trimspace(replace(local.udc_name, "/", "-"))

  # Generate the CSV content from the template
  udc_csv = templatefile("${path.module}/templates/alloydbPubSub.tpl", {
    udc_name        = local.udc_name_safe
    description     = "GDP GCP AlloyDB connector for ${var.alloydb_cluster_id}"
    credential_name = var.udc_gcp_credential
    gcp_project_id  = var.gcp_project_id
    topic_name      = var.pubsub_topic_id
    sub_name        = var.pubsub_subscription_id
    max_messages    = var.max_messages
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