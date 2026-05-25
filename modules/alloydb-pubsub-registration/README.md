# AlloyDB Pub/Sub Registration Module

This module configures Guardium Data Protection to monitor Google Cloud AlloyDB clusters via Pub/Sub.

## Overview

This module automates the registration of AlloyDB audit logs with Guardium Data Protection using Google Cloud Pub/Sub as the transport mechanism. It creates a Universal Connector configuration that subscribes to AlloyDB audit log messages published to a Pub/Sub topic.

## Prerequisites

1. **AlloyDB Cluster**: An existing AlloyDB cluster with audit logging enabled
2. **Pub/Sub Setup**: 
   - A Pub/Sub topic configured to receive AlloyDB audit logs
   - A Pub/Sub subscription created for the topic
3. **GCP Credentials**: Service account credentials configured in Guardium with appropriate permissions:
   - `pubsub.subscriptions.consume`
   - `pubsub.subscriptions.get`
4. **Guardium Setup**:
   - Guardium Data Protection instance with Universal Connector support
   - OAuth client registered (use `grdapi register_oauth_client`)
   - GCP credentials configured in Guardium

## Usage

```hcl
module "alloydb_pubsub_registration" {
  source = "path/to/terraform-guardium-common/modules/alloydb-pubsub-registration"

  # GCP Configuration
  gcp_region             = "us-central1"
  gcp_project_id         = "my-gcp-project"
  alloydb_cluster_id     = "my-alloydb-cluster"
  pubsub_subscription_id = "alloydb-audit-logs-sub"

  # Guardium Configuration
  udc_gcp_credential = "gcp-service-account-creds"
  gdp_client_id      = "my-client-id"
  gdp_client_secret  = var.gdp_client_secret
  gdp_server         = "guardium.example.com"
  gdp_port           = "8443"
  gdp_username       = "admin"
  gdp_password       = var.gdp_password
  gdp_mu_host        = "guardium-mu-1,guardium-mu-2"

  # Optional: Pub/Sub Configuration
  threads      = 8
  max_messages = 100
  ack_deadline = 60
}
```

## Variables

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| `gcp_region` | GCP region where the AlloyDB cluster is located | `string` |
| `gcp_project_id` | GCP project ID | `string` |
| `alloydb_cluster_id` | AlloyDB cluster identifier to be monitored | `string` |
| `pubsub_subscription_id` | Pub/Sub subscription ID for AlloyDB audit logs | `string` |
| `udc_gcp_credential` | Name of GCP credential defined in Guardium | `string` |
| `gdp_client_id` | Client ID from OAuth registration | `string` |
| `gdp_client_secret` | Client secret from OAuth registration | `string` |
| `gdp_server` | Guardium Central Manager hostname/IP | `string` |
| `gdp_username` | Guardium Web UI username | `string` |
| `gdp_password` | Guardium Web UI password | `string` |
| `gdp_mu_host` | Comma-separated list of Guardium Managed Units | `string` |

### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `udc_name` | Name for universal connector | `string` | `"alloydb-gdp"` |
| `gdp_port` | Guardium Central Manager port | `string` | `"8443"` |
| `enable_universal_connector` | Enable/disable universal connector | `bool` | `true` |
| `csv_start_position` | Start position for UDC (beginning, end) | `string` | `"end"` |
| `threads` | Number of threads for Pub/Sub consumer | `number` | `8` |
| `max_messages` | Max messages to pull in single request | `number` | `100` |
| `ack_deadline` | Acknowledgement deadline in seconds | `number` | `60` |

## Outputs

This module uses the `connect-datasource-to-uc` module from the Guardium GDP provider, which handles the registration with Guardium.

## Setting Up AlloyDB Audit Logging with Pub/Sub

1. **Enable AlloyDB Audit Logging**:
   ```bash
   gcloud alloydb clusters update CLUSTER_NAME \
     --region=REGION \
     --enable-audit-log
   ```

2. **Create Pub/Sub Topic**:
   ```bash
   gcloud pubsub topics create alloydb-audit-logs
   ```

3. **Configure Log Sink**:
   ```bash
   gcloud logging sinks create alloydb-audit-sink \
     pubsub.googleapis.com/projects/PROJECT_ID/topics/alloydb-audit-logs \
     --log-filter='resource.type="alloydb.googleapis.com/Instance"'
   ```

4. **Create Subscription**:
   ```bash
   gcloud pubsub subscriptions create alloydb-audit-logs-sub \
     --topic=alloydb-audit-logs \
     --ack-deadline=60
   ```

5. **Grant Permissions**: Ensure the service account has necessary permissions on the subscription.

## Notes

- The module generates a unique UDC name based on region, cluster ID, and project ID
- Audit logs are consumed from Pub/Sub in real-time
- The `ack_deadline` should be set based on your processing requirements
- Multiple threads can be configured for parallel message processing

## License

Copyright IBM Corp. 2025
SPDX-License-Identifier: Apache-2.0