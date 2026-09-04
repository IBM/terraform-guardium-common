# Copyright (c) IBM Corporation
# SPDX-License-Identifier: Apache-2.0

# GDP Edge Deployment with Custom Provider
# Deploys Guardium Data Protection Edge components using guardium-data-protection

terraform {
  required_providers {
    guardium-data-protection = {
      source  = "IBM/guardium-data-protection"
      version = "~> 1.5.0"
    }
  }
}

# ============================================================================
# Provider Configuration
# ============================================================================

provider "guardium-data-protection" {
  cm_url       = var.cm_url
  oauth_token  = var.oauth_token
  cm_cert_path = var.cm_cert_path
  platform     = var.platform

  # SSH (K3S / OpenShift)
  ssh_user             = var.ssh_user
  ssh_password         = var.ssh_password
  ssh_key_path         = var.ssh_key_path
  ssh_known_hosts_file = var.ssh_known_hosts_file

  # AWS EKS (only needed for eks platform)
  aws_region        = var.aws_region
  aws_profile       = var.aws_profile
  aws_access_key    = var.aws_access_key
  aws_secret_key    = var.aws_secret_key
  eks_ssh_user      = var.eks_ssh_user
  eks_ssh_key_path  = var.eks_ssh_key_path
  eks_hostname_type = var.eks_hostname_type

  # OpenShift native OAuth (alternative to 'oc login')
  ocp_server               = var.ocp_server
  ocp_username             = var.ocp_username
  ocp_password             = var.ocp_password
  ocp_token                = var.ocp_token
  ocp_insecure_skip_verify = var.ocp_insecure_skip_verify
}

# ============================================================================
# Deploy Edge
# ============================================================================

resource "guardium-data-protection_edge_deploy" "edge" {

  # Bundle source - use either edge_name (download from CM) or bundle_directory (local)
  edge_name             = var.edge_name
  edge_bundle_directory = var.edge_bundle_directory

  # Platform (overrides provider-level if set)
  platform = var.platform

  # K3S configuration
  k3s_master_node = var.k3s_master_node
  k3s_nodes       = var.k3s_nodes

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # Monitoring configuration
  monitor_max_attempts   = var.monitor_max_attempts
  monitor_sleep_interval = var.monitor_sleep_interval

  # General
  cleanup_bundle          = var.cleanup_bundle
  external_image_registry = var.external_image_registry
}
