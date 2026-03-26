# Copyright (c) IBM Corporation
# SPDX-License-Identifier: Apache-2.0

# K3S Installation Variables
# Mirrors k3s-install/variables.tf but for the custom provider

variable "cluster_name" {
  description = "Name of the K3S cluster"
  type        = string
}

variable "master_nodes" {
  description = "List of master node hostnames (FQDNs)"
  type        = list(string)
}

variable "worker_nodes" {
  description = "List of worker node hostnames (FQDNs). Empty for single-node cluster."
  type        = list(string)
  default     = []
}

variable "ssh_user" {
  description = "SSH username for connecting to nodes. Defaults to 'root'. Can also be set via K3S_SSH_USER env var."
  type        = string
  default     = "root"
}

variable "ssh_password" {
  description = "SSH password for connecting to nodes"
  type        = string
  sensitive   = true
}

variable "k3s_airgap_install" {
  description = "Enable airgap installation"
  type        = bool
  default     = true
}

variable "airgap_installation_path" {
  description = "Local path to store airgap installation binary files"
  type        = string
}

variable "k3s_version" {
  description = "K3S version to install (e.g., v1.32.3, v1.33.1)"
  type        = string
  default     = "v1.32.3"

  validation {
    condition     = can(regex("^v[0-9]+\\.[0-9]+\\.[0-9]+$", var.k3s_version))
    error_message = "K3S version must be in format vX.Y.Z (e.g., v1.32.3)."
  }
}

variable "k3s_token" {
  description = "Token for K3S cluster authentication"
  type        = string
  default     = "edge1234"
  sensitive   = true
}

variable "k3s_install_options" {
  description = "K3S installation options"
  type = object({
    disable_traefik   = bool
    taint_masters     = bool
    node_wait_timeout = string
  })
  default = {
    disable_traefik   = true
    taint_masters     = true
    node_wait_timeout = "600s"
  }
}

variable "ssh_options" {
  description = "SSH connection options"
  type = object({
    connect_timeout       = number
    server_alive_interval = number
    server_alive_count    = number
  })
  default = {
    connect_timeout       = 30
    server_alive_interval = 10
    server_alive_count    = 3
  }
}
