// Copyright (c) IBM Corporation
// SPDX-License-Identifier: Apache-2.0

# Rook-Ceph Deploy Configuration

This directory contains Terraform configuration for deploying Rook-Ceph storage using the `terraform-provider-guardium-data-protection` provider. Supports both K3S and OpenShift platforms.

## Usage

### Initialize Terraform

```bash
terraform init
```

### Plan the Deployment

```bash
terraform plan
```

### Apply the Configuration

```bash
terraform apply
```

### Destroy Rook-Ceph

```bash
terraform destroy
```

## Configuration

### K3S Test Cluster (single node, worker_count <= 1)

```hcl
cluster_name    = "my-k3s-test"
platform        = "k3s"
target_node     = "k3s-master.example.com"
worker_count    = 0
ssh_user        = "root"
ssh_password    = "your-password"
rook_ceph_version = "v1.15.4"
rook_ceph_installation_path = "path"
airgap_install  = true
```

### K3S Production Cluster (multi-node, worker_count >= 2)

```hcl
cluster_name    = "my-k3s-prod"
platform        = "k3s"
target_node     = "k3s-master.example.com"
worker_count    = 3
ssh_user        = "root"
ssh_password    = "your-password"
rook_ceph_version = "v1.15.4"
rook_ceph_installation_path = "path"
airgap_install  = true
```

### OpenShift Cluster

```hcl
cluster_name    = "my-ocp-cluster"
platform        = "openshift"
target_node     = "ocp-api-node.example.com"
ssh_user        = "root"
ssh_password    = "your-password"
rook_ceph_version = "v1.15.4"
rook_ceph_installation_path = "path"
airgap_install  = true
```

### Optional: Rook-Ceph Configuration

```hcl
rook_ceph_config = {
  set_as_default_storage = true
  disable_local_path     = true
  pod_wait_timeout       = "600s"
  sleep_between_steps    = 60
}
```

### Optional: SSH Options

```hcl
ssh_options = {
  connect_timeout       = 30
  server_alive_interval = 60
  server_alive_count    = 5
}
```

## Outputs

After successful deployment, you'll get:

- `cluster_id` - Rook-Ceph cluster resource ID
- `cluster_name` - Name of the cluster
- `platform` - Platform type (k3s or openshift)
- `cluster_type` - Cluster type: test or production (K3S only)
- `namespace` - Kubernetes namespace where Rook-Ceph is installed
- `cephfs_storage_class` - CephFS storage class name
- `block_storage_class` - RBD block storage class name
- `rook_ceph_version` - Installed Rook-Ceph version
- `cluster_summary` - Summary of the Rook-Ceph installation

## Troubleshooting

### Provider Not Found

If you get "provider not found" errors:

1. Verify Artifactory configuration in `~/.terraformrc`
2. Check authentication (`.netrc` or credentials block)
3. Re-initialize Terraform:
```bash
rm -rf .terraform .terraform.lock.hcl
terraform init
```

### Authentication Errors

Verify your SSH credentials:

```bash
echo $ROOK_CEPH_SSH_USER
echo $ROOK_CEPH_SSH_PASSWORD
```

Or check your `terraform.tfvars` file.

### Timeout Issues

Increase the pod wait timeout:

```hcl
rook_ceph_config = {
  pod_wait_timeout    = "900s"
  sleep_between_steps = 90
}
```

## Support

For issues with the custom provider, see:
- Provider README: `../provider/terraform-provider-rook-ceph-native/README.md`
- Provider source code: `../provider/terraform-provider-rook-ceph-native/`

For Rook-Ceph documentation, see: https://rook.io/docs/rook/latest/
