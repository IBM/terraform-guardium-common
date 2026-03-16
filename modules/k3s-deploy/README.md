# K3S Deploy Configuration

This directory contains Terraform configuration for installing K3S on existing nodes using the `terraform-provider-guardium-data-protection` provider. Cluster information (node hostnames) is typically obtained from `fyre-vm-deploy` outputs.

## Prerequisites (Just for internal test purpose)

1. **Configure Terraform to Use IBM Artifactory**

Create or update `~/.terraformrc`:

```hcl
provider_installation {
  network_mirror {
    url = "https://na.artifactory.swg-devops.com/artifactory/sec-guardium-next-gen-terraform-local/"
    include = ["ibm/*"]
  }
  direct {
    exclude = ["ibm/*"]
  }
}
```

**Authentication Options:**

Option A - Using `.netrc` (Recommended):
```bash
cat >> ~/.netrc << EOF
machine na.artifactory.swg-devops.com
  login your-email@ibm.com
  password your-api-key
EOF
chmod 600 ~/.netrc
```

Option B - Using credentials block in `~/.terraformrc`:
```hcl
credentials "na.artifactory.swg-devops.com" {
  token = "your-api-key"
}
```

Option C - Using environment variables:
```bash
export ARTIFACTORY_USERNAME="your-email@ibm.com"
export ARTIFACTORY_API_KEY="your-api-key"
```

2. **Set Up Credentials**

Copy the example variables file and configure your values:

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your cluster details
```

Or use environment variables for SSH credentials:

```bash
export K3S_SSH_USER="root"
export K3S_SSH_PASSWORD="your-password"
```

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
echo $K3S_SSH_USER
echo $K3S_SSH_PASSWORD
```

Or check your `terraform.tfvars` file.

### Timeout Issues

Increase the node wait timeout or installation timeout:

```hcl
k3s_install_options = {
  node_wait_timeout = "900s"
}

install_timeout_minutes = 60
```

## Support

For issues with the custom provider, see:
- Provider README: `../provider/terraform-provider-k3s-native/README.md`
- Provider source code: `../provider/terraform-provider-k3s-native/`

For K3S documentation, see: https://docs.k3s.io/
