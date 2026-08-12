# Edge Deploy Configuration

This directory contains Terraform configuration for deploying Guardium Data Protection (GDP) Edge components using the `terraform-provider-guardium-data-protection` provider. Supports K3S, AWS EKS, and OpenShift platforms.

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

### Destroy Edge Deployment

```bash
terraform destroy
```

## Configuration

### Scenario 1: K3S with Remote Bundle Download

Downloads the edge bundle from Central Manager and deploys to a K3S cluster.

```hcl
edge_name   = "my-edge-cluster"
cm_url      = "https://guardium-insights.example.com"
oauth_token = "your-oauth-token-here"

platform        = "k3s"
k3s_master_node = "master.example.com"
k3s_nodes       = []  # Empty to auto-detect from kubectl
ssh_user        = "root"
ssh_password    = "your-ssh-password"
# ssh_known_hosts_file = "/path/to/known_hosts"  # Optional: verify node SSH host keys
```

### Scenario 2: K3S with Local Bundle

Uses a pre-downloaded edge bundle from a local directory.

```hcl
edge_bundle_directory = "/path/to/local/edge-bundle"
platform              = "k3s"
k3s_master_node       = "node1.example.com"
k3s_nodes             = ["node1.example.com", "node2.example.com"]
ssh_user              = "root"
ssh_password          = "password"
```

### Scenario 3: AWS EKS with Remote Bundle Download

Deploys to an AWS EKS cluster.

```hcl
edge_name   = "my-edge-cluster"
cm_url      = "https://guardium-insights.example.com"
oauth_token = "your-oauth-token-here"

platform         = "eks"
eks_cluster_name = "my-eks-cluster"
aws_region       = "us-east-1"
aws_profile      = "default"  # OR use aws_access_key/aws_secret_key
eks_ssh_user     = "ec2-user"
eks_ssh_key_path = "/path/to/eks-key.pem"
eks_hostname_type = "public"
```

### Scenario 4: OpenShift with kubeconfig

Requires `oc login` before running Terraform.

```hcl
edge_name   = "my-edge-cluster"
cm_url      = "https://guardium-insights.example.com"
oauth_token = "your-oauth-token-here"

platform = "openshift"
# Ensure you are logged in with: oc login
```

### Scenario 5: OpenShift with Native OAuth

Authenticates directly to OpenShift without needing `oc login`.

```hcl
edge_name   = "my-edge-cluster"
cm_url      = "https://guardium-insights.example.com"
oauth_token = "your-oauth-token-here"

platform = "openshift"

# Option A: Username/Password authentication
ocp_server   = "https://api.cluster.example.com:6443"
ocp_username = "admin"
ocp_password = "your-password"

# Option B: Token authentication (alternative to username/password)
# ocp_server = "https://api.cluster.example.com:6443"
# ocp_token  = "sha256~your-token-here"  # Get via: oc whoami -t

# Skip TLS verification (for self-signed certs)
ocp_insecure_skip_verify = true
```

### Optional: Monitoring Configuration

```hcl
monitor_max_attempts   = 180  # ~30 min with 10s interval
monitor_sleep_interval = 10
```

### Optional: General Configuration

```hcl
cleanup_bundle = true  # Cleanup downloaded bundle directory on destroy

# Set to true when using an external image registry (e.g. Docker Hub, Quay)
# instead of the CM private registry. Skips registry certificate installation.
external_image_registry = false
```

### Optional: SSH Host Key Verification

By default, SSH connections to K3S/EKS nodes do not verify the remote host key. To enable
verification, point `ssh_known_hosts_file` at a `known_hosts` file:

```hcl
ssh_known_hosts_file = "/path/to/known_hosts"
```

## Outputs

After successful deployment, you'll get:

- `edge_namespace` - Kubernetes namespace where Edge components are deployed
- `registry_url` - Container registry URL used by the Edge deployment
- `platform` - Platform where Edge is deployed
- `deployment_status` - Final deployment status
- `work_dir` - Working directory for the edge bundle
- `access_instructions` - Instructions to check Edge deployment status
