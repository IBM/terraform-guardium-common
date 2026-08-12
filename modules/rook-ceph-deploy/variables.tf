# Copyright (c) IBM Corporation
# SPDX-License-Identifier: Apache-2.0

# ============================================================================
# Cluster Configuration
# ============================================================================

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
}

variable "platform" {
  description = "Target platform: 'k3s' or 'openshift'"
  type        = string
  validation {
    condition     = contains(["k3s", "openshift"], var.platform)
    error_message = "Platform must be 'k3s' or 'openshift'."
  }
}

variable "target_node" {
  description = "Target node hostname for SSH operations (primary master for K3S, API node for OpenShift)"
  type        = string
}

variable "worker_count" {
  description = "Number of worker nodes. For K3S: 0-1 = test cluster, 2+ = production. Not used for OpenShift."
  type        = number
  default     = 0
}

variable "taint_masters" {
  description = "Whether master nodes are tainted (not schedulable for regular workloads). When true with worker_count=1, sets CSI provisioner replicas to 1 to avoid anti-affinity scheduling failures."
  type        = bool
  default     = false
}

# ============================================================================
# Rook-Ceph Configuration
# ============================================================================

variable "rook_ceph_version" {
  description = "Rook-Ceph version to install"
  type        = string
  default     = "v1.15.4"
}

variable "rook_ceph_installation_path" {
  description = "Rook-Ceph installation local directory"
  type        = string
}

variable "rook_ceph_airgap_install" {
  description = "Enable airgap installation"
  type        = bool
  default     = true
}

variable "rook_ceph_config" {
  description = "Rook-Ceph installation configuration"
  type = object({
    set_as_default_storage = optional(bool, true)
    disable_local_path     = optional(bool, true)
    pod_wait_timeout       = optional(string, "600s")
    sleep_between_steps    = optional(number, 60)
  })
  default = {}
}

# ============================================================================
# SSH Configuration
# ============================================================================

variable "ssh_user" {
  description = "SSH user for remote operations (can also be set via ROOK_CEPH_SSH_USER env var)"
  type        = string
  default     = "root"
}

variable "ssh_password" {
  description = "SSH password for remote operations (can also be set via ROOK_CEPH_SSH_PASSWORD env var)"
  type        = string
  sensitive   = true
}

variable "ssh_options" {
  description = "SSH connection options"
  type = object({
    connect_timeout       = optional(number, 30)
    server_alive_interval = optional(number, 10)
    server_alive_count    = optional(number, 3)
    known_hosts_file      = optional(string, "")
  })
  default = {}
}
