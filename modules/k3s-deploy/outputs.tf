# Copyright (c) IBM Corporation
# SPDX-License-Identifier: Apache-2.0

# K3S Installation Outputs

output "cluster_name" {
  description = "Name of the K3S cluster"
  value       = guardium-data-protection_k3s_cluster.main.cluster_name
}

output "k3s_version" {
  description = "Installed K3S version"
  value       = guardium-data-protection_k3s_cluster.main.k3s_version
}

output "primary_master" {
  description = "Primary master node hostname"
  value       = guardium-data-protection_k3s_cluster.main.primary_master
}

output "master_nodes" {
  description = "List of all master node hostnames"
  value       = var.master_nodes
}

output "worker_nodes" {
  description = "List of all worker node hostnames"
  value       = var.worker_nodes
}

output "cluster_type" {
  description = "Type of cluster deployment"
  value       = guardium-data-protection_k3s_cluster.main.cluster_type
}

output "kubeconfig_location" {
  description = "Location of kubeconfig file on master node"
  value       = guardium-data-protection_k3s_cluster.main.kubeconfig_path
}

output "access_instructions" {
  description = "Instructions to access the K3S cluster"
  value       = <<-EOT
    To access the K3S cluster:

    1. SSH to the primary master node:
       ssh root@${guardium-data-protection_k3s_cluster.main.primary_master}

    2. Set KUBECONFIG environment variable:
       export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

    3. Verify cluster status:
       kubectl get nodes
       kubectl cluster-info
  EOT
}

output "cluster_summary" {
  description = "Summary of the K3S cluster configuration"
  value = {
    cluster_name     = var.cluster_name
    k3s_version      = var.k3s_version
    cluster_type     = guardium-data-protection_k3s_cluster.main.cluster_type
    master_count     = length(var.master_nodes)
    worker_count     = length(var.worker_nodes)
    total_nodes      = length(var.master_nodes) + length(var.worker_nodes)
    primary_master   = guardium-data-protection_k3s_cluster.main.primary_master
    traefik_disabled = var.k3s_install_options.disable_traefik
    masters_tainted  = var.k3s_install_options.taint_masters
  }
}
