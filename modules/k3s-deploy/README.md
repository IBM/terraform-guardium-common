# K3S Deploy Configuration

This directory contains Terraform configuration for installing K3S on existing nodes using the `terraform-provider-guardium-data-protection` provider. 

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

### Destroy K3S

```bash
terraform destroy
```

## Configuration

### Single-Node Cluster

```hcl
cluster_name  = "my-test-cluster"
domain_suffix = "fyre.ibm.com"

master_nodes = [
  "my-test-cluster-master1.fyre.ibm.com"
]

worker_nodes = []

ssh_user     = "root"
ssh_password = "your-fyre-root-password"

k3s_version = "v1.32.3"
k3s_token   = "edge1234"
```

### Multi-Node Cluster (3 Workers)

```hcl
cluster_name  = "my-multi-node-cluster"
domain_suffix = "fyre.ibm.com"

master_nodes = [
  "my-multi-node-cluster-master1.fyre.ibm.com"
]

worker_nodes = [
  "my-multi-node-cluster-worker1.fyre.ibm.com",
  "my-multi-node-cluster-worker2.fyre.ibm.com",
  "my-multi-node-cluster-worker3.fyre.ibm.com"
]

ssh_user     = "root"
ssh_password = "your-fyre-root-password"

k3s_version = "v1.32.3"
k3s_token   = "edge1234"
```

### HA Cluster (3 Masters + 5 Workers)

```hcl
cluster_name  = "my-ha-cluster"
domain_suffix = "fyre.ibm.com"

master_nodes = [
  "my-ha-cluster-master1.fyre.ibm.com",
  "my-ha-cluster-master2.fyre.ibm.com",
  "my-ha-cluster-master3.fyre.ibm.com"
]

worker_nodes = [
  "my-ha-cluster-worker1.fyre.ibm.com",
  "my-ha-cluster-worker2.fyre.ibm.com",
  "my-ha-cluster-worker3.fyre.ibm.com",
  "my-ha-cluster-worker4.fyre.ibm.com",
  "my-ha-cluster-worker5.fyre.ibm.com"
]

ssh_user     = "root"
ssh_password = "your-fyre-root-password"

k3s_version = "v1.32.3"
k3s_token   = "edge1234"
```

### Airgap Installation

```hcl
k3s_airgap_install       = true
airgap_installation_path = "/path/to/k3s-airgap-binaries"
```

### Optional: K3S Installation Options

```hcl
k3s_install_options = {
  disable_traefik   = true    # Disable Traefik ingress controller
  taint_masters     = true    # Taint master nodes to prevent workload scheduling
  node_wait_timeout = "600s"  # Timeout for node readiness check
}
```

### Optional: SSH Options

```hcl
ssh_options = {
  connect_timeout       = 30  # SSH connection timeout in seconds
  server_alive_interval = 10  # Interval for keepalive messages
  server_alive_count    = 3   # Number of keepalive messages before disconnect
}
```

### Optional: Installation Timeout

```hcl
install_timeout_minutes = 45  # Maximum time for K3S installation
```

## Outputs

After successful deployment, you'll get:

- `cluster_name` - Name of the K3S cluster
- `k3s_version` - Installed K3S version
- `primary_master` - Primary master node hostname
- `master_nodes` - List of all master node hostnames
- `worker_nodes` - List of all worker node hostnames
- `cluster_type` - Type of cluster deployment
- `kubeconfig_location` - Location of kubeconfig file on master node
- `access_instructions` - Instructions to access the K3S cluster
- `cluster_summary` - Summary of the K3S cluster configuration
