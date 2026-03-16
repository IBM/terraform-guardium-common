# Rook-Ceph Installation using Custom Terraform Provider
# Supports both K3S and OpenShift platforms
terraform {
  required_providers {
    guardium-data-protection = {
      # For internal testing with IBM Artifactory
      source  = "registry.terraform.io/ibm/guardium-data-protection"
      # For public release (uncomment when published to HashiCorp registry)
      # source  = "hashicorp.com/ibm/guardium-data-protection"
      version = "1.0.0"
    }
  }
}

provider "guardium-data-protection" {
  ssh_user     = var.ssh_user
  ssh_password = var.ssh_password

  connect_timeout        = var.ssh_options.connect_timeout
  server_alive_interval  = var.ssh_options.server_alive_interval
  server_alive_count     = var.ssh_options.server_alive_count
}

resource "guardium-data-protection_rook_ceph_cluster" "this" {
  cluster_name                = var.cluster_name
  platform                    = var.platform
  target_node                 = var.target_node
  rook_ceph_version           = var.rook_ceph_version
  rook_ceph_installation_path = var.rook_ceph_installation_path
  airgap_install              = var.rook_ceph_airgap_install
  worker_count                = var.worker_count
  taint_masters               = var.taint_masters
  set_as_default_storage      = var.rook_ceph_config.set_as_default_storage
  disable_local_path          = var.rook_ceph_config.disable_local_path
  pod_wait_timeout            = var.rook_ceph_config.pod_wait_timeout
  sleep_between_steps         = var.rook_ceph_config.sleep_between_steps
}
