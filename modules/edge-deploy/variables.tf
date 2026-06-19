# Copyright (c) IBM Corporation
# SPDX-License-Identifier: Apache-2.0

# GDP Edge Deployment - Variables

# ============================================================================
# Bundle Source Configuration
# ============================================================================

variable "edge_name" {
  description = "Name of the edge to deploy (required if downloading bundle from CM)"
  type        = string
  default     = ""
}

variable "edge_bundle_directory" {
  description = "Path to local edge bundle directory. If empty, bundle will be downloaded from CM."
  type        = string
  default     = ""
}

variable "cm_url" {
  description = "Guardium Insights Central Manager URL"
  type        = string
  default     = ""
}

variable "oauth_token" {
  description = "OAuth token for CM authentication"
  type        = string
  default     = ""
  sensitive   = true
}

# ============================================================================
# Platform Configuration
# ============================================================================

variable "platform" {
  description = "Target platform: 'k3s', 'eks', or 'openshift'"
  type        = string

  validation {
    condition     = contains(["k3s", "eks", "openshift"], var.platform)
    error_message = "Platform must be one of: k3s, eks, openshift."
  }
}

# ============================================================================
# SSH Configuration (K3S / OpenShift)
# ============================================================================

variable "ssh_user" {
  description = "SSH user for K3S/OpenShift nodes"
  type        = string
  default     = "root"
}

variable "ssh_password" {
  description = "SSH password for K3S/OpenShift nodes"
  type        = string
  default     = ""
  sensitive   = true
}

variable "ssh_key_path" {
  description = "Path to SSH private key for K3S/OpenShift nodes"
  type        = string
  default     = ""
}

# ============================================================================
# K3S Platform Configuration
# ============================================================================

variable "k3s_master_node" {
  description = "K3S master node hostname/IP for kubeconfig retrieval"
  type        = string
  default     = ""
}

variable "k3s_nodes" {
  description = "List of K3S node hostnames/IPs for certificate installation. Empty to auto-detect."
  type        = list(string)
  default     = []
}

# ============================================================================
# AWS EKS Platform Configuration
# ============================================================================

variable "eks_cluster_name" {
  description = "AWS EKS cluster name"
  type        = string
  default     = ""
}

variable "aws_region" {
  description = "AWS region for EKS cluster"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile name"
  type        = string
  default     = ""
}

variable "aws_access_key" {
  description = "AWS access key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
  default     = ""
  sensitive   = true
}

variable "eks_ssh_user" {
  description = "SSH user for EKS nodes"
  type        = string
  default     = "ec2-user"
}

variable "eks_ssh_key_path" {
  description = "Path to SSH private key for EKS nodes"
  type        = string
  default     = ""
}

variable "eks_hostname_type" {
  description = "Type of hostname for EKS nodes: 'public' or 'private'"
  type        = string
  default     = "public"

  validation {
    condition     = contains(["public", "private"], var.eks_hostname_type)
    error_message = "EKS hostname type must be 'public' or 'private'."
  }
}

# ============================================================================
# OpenShift Native OAuth Configuration
# ============================================================================
# When these variables are set, the provider will authenticate directly to
# OpenShift using OAuth instead of relying on 'oc login' / kubeconfig.

variable "ocp_server" {
  description = "OpenShift API server URL (e.g., https://api.cluster.example.com:6443)"
  type        = string
  default     = ""
}

variable "ocp_username" {
  description = "OpenShift username for OAuth authentication"
  type        = string
  default     = ""
}

variable "ocp_password" {
  description = "OpenShift password for OAuth authentication"
  type        = string
  default     = ""
  sensitive   = true
}

variable "ocp_token" {
  description = "OpenShift OAuth token (alternative to username/password, can be obtained via 'oc whoami -t')"
  type        = string
  default     = ""
  sensitive   = true
}

variable "ocp_insecure_skip_verify" {
  description = "Skip TLS certificate verification for OpenShift API server"
  type        = bool
  default     = false
}

# ============================================================================
# Monitoring Configuration
# ============================================================================

variable "monitor_max_attempts" {
  description = "Maximum polling attempts for deployment monitoring (default: 180)"
  type        = number
  default     = 180
}

variable "monitor_sleep_interval" {
  description = "Sleep interval in seconds between monitoring polls (default: 10)"
  type        = number
  default     = 10
}

# ============================================================================
# General Configuration
# ============================================================================

variable "cleanup_bundle" {
  description = "Whether to cleanup downloaded bundle directory on destroy"
  type        = bool
  default     = true
}

variable "external_image_registry" {
  description = "Set to true when using an external image registry (e.g. Docker Hub, Quay) instead of the CM private registry. Skips registry certificate installation on cluster nodes."
  type        = bool
  default     = false
}
