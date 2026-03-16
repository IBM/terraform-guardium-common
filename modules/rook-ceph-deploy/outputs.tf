# ============================================================================
# Rook-Ceph Cluster Outputs
# ============================================================================

output "cluster_id" {
  description = "Rook-Ceph cluster resource ID"
  value       = guardium-data-protection_rook_ceph_cluster.this.id
}

output "cluster_name" {
  description = "Name of the cluster"
  value       = guardium-data-protection_rook_ceph_cluster.this.cluster_name
}

output "platform" {
  description = "Platform type (k3s or openshift)"
  value       = guardium-data-protection_rook_ceph_cluster.this.platform
}

output "cluster_type" {
  description = "Cluster type: test or production (K3S only)"
  value       = guardium-data-protection_rook_ceph_cluster.this.cluster_type
}

output "namespace" {
  description = "Kubernetes namespace where Rook-Ceph is installed"
  value       = guardium-data-protection_rook_ceph_cluster.this.namespace
}

output "cephfs_storage_class" {
  description = "CephFS storage class name"
  value       = guardium-data-protection_rook_ceph_cluster.this.cephfs_storage_class
}

output "block_storage_class" {
  description = "RBD block storage class name"
  value       = guardium-data-protection_rook_ceph_cluster.this.block_storage_class
}

output "rook_ceph_version" {
  description = "Installed Rook-Ceph version"
  value       = guardium-data-protection_rook_ceph_cluster.this.rook_ceph_version
}

output "cluster_summary" {
  description = "Summary of the Rook-Ceph installation"
  value = <<-EOT
    Rook-Ceph Installation Summary:
      Cluster:        ${guardium-data-protection_rook_ceph_cluster.this.cluster_name}
      Platform:       ${guardium-data-protection_rook_ceph_cluster.this.platform}
      Cluster Type:   ${guardium-data-protection_rook_ceph_cluster.this.cluster_type}
      Version:        ${guardium-data-protection_rook_ceph_cluster.this.rook_ceph_version}
      Namespace:      ${guardium-data-protection_rook_ceph_cluster.this.namespace}
      CephFS SC:      ${guardium-data-protection_rook_ceph_cluster.this.cephfs_storage_class}
      Block SC:       ${guardium-data-protection_rook_ceph_cluster.this.block_storage_class}
  EOT
}
