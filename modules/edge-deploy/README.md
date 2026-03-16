# Edge Deploy Configuration

This directory contains Terraform configuration for deploying Guardium Data Protection (GDP) Edge components using the `terraform-provider-guardium-data-protection` provider. Supports K3S, AWS EKS, and OpenShift platforms.

## Prerequisites (Just for internal test purpose)

1. **Configure Terraform to Use IBM Artifactory **

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
# Edit terraform.tfvars with your deployment details
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

## Outputs

After successful deployment, you'll get:

- `edge_namespace` - Kubernetes namespace where Edge components are deployed
- `registry_url` - Container registry URL used by the Edge deployment
- `platform` - Platform where Edge is deployed
- `deployment_status` - Final deployment status
- `work_dir` - Working directory for the edge bundle
- `access_instructions` - Instructions to check Edge deployment status

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

### Bundle Download Errors

Verify your CM credentials:

```hcl
cm_url      = "https://guardium-insights.example.com"
oauth_token = "your-valid-token"
```

Or use a local bundle instead:

```hcl
edge_bundle_directory = "/path/to/local/edge-bundle"
```

### SSH Authentication Errors

For K3S, verify SSH credentials:

```bash
ssh root@master.example.com
```

Use either `ssh_password` or `ssh_key_path`, not both.

### EKS Authentication Errors

Verify AWS credentials and cluster access:

```bash
aws sts get-caller-identity --profile your-profile
aws eks update-kubeconfig --name your-cluster --region us-east-1
```

### OpenShift Authentication Errors

For kubeconfig mode, ensure you're logged in:

```bash
oc login https://api.cluster.example.com:6443
oc whoami
```

For native OAuth mode, verify the `ocp_server`, `ocp_username`/`ocp_password` or `ocp_token` values.

### Timeout Issues

Increase monitoring attempts:

```hcl
monitor_max_attempts   = 360  # ~60 min with 10s interval
monitor_sleep_interval = 10
```

## Support

For issues with the custom provider, see:
- Provider README: `../provider/terraform-provider-gdp-edge-native/README.md`
- Provider source code: `../provider/terraform-provider-gdp-edge-native/`
