# Copyright (c) IBM Corporation
# SPDX-License-Identifier: Apache-2.0

# K3S Installation with Custom Provider
# Installs K3S on existing nodes using terraform-provider-k3s

terraform {
  required_providers {
    guardium-data-protection = {
      # For internal testing with IBM Artifactory
      # source  = "registry.terraform.io/ibm/guardium-data-protection"
      # For public release (uncomment when published to HashiCorp registry)
      source  = "hashicorp.com/ibm/guardium-data-protection"
      version = "~> 1.3.8"
    }
  }
}

# ============================================================================
# Provider Configuration
# ============================================================================

provider "guardium-data-protection" {
  k3s_ssh_user              = var.ssh_user
  k3s_ssh_password          = var.ssh_password
  k3s_connect_timeout       = var.ssh_options.connect_timeout
  k3s_server_alive_interval = var.ssh_options.server_alive_interval
  k3s_server_alive_count    = var.ssh_options.server_alive_count
}

# ============================================================================
# Install K3S Cluster
# ============================================================================

resource "guardium-data-protection_k3s_cluster" "main" {
  cluster_name            = var.cluster_name
  master_nodes            = var.master_nodes
  worker_nodes            = var.worker_nodes
  k3s_version             = var.k3s_version
  k3s_token               = var.k3s_token
  airgap_install          = var.k3s_airgap_install
  airgap_installation_path = var.airgap_installation_path
  disable_traefik         = var.k3s_install_options.disable_traefik
  taint_masters           = var.k3s_install_options.taint_masters
  node_wait_timeout       = var.k3s_install_options.node_wait_timeout
}
