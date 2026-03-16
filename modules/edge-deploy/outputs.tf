# GDP Edge Deployment - Outputs

output "edge_namespace" {
  description = "Kubernetes namespace where Edge components are deployed"
  value       = guardium-data-protection_deployment.edge.edge_namespace
}

output "registry_url" {
  description = "Container registry URL used by the Edge deployment"
  value       = guardium-data-protection_deployment.edge.registry_url
}

output "platform" {
  description = "Platform where Edge is deployed"
  value       = guardium-data-protection_deployment.edge.platform
}

output "deployment_status" {
  description = "Final deployment status"
  value       = guardium-data-protection_deployment.edge.deployment_status
}

output "work_dir" {
  description = "Working directory for the edge bundle"
  value       = guardium-data-protection_deployment.edge.work_dir
}

output "access_instructions" {
  description = "Instructions to check Edge deployment status"
  value       = <<-EOT
    Edge Deployment Summary:
      Namespace: ${guardium-data-protection_deployment.edge.edge_namespace}
      Platform:  ${guardium-data-protection_deployment.edge.platform}
      Status:    ${guardium-data-protection_deployment.edge.deployment_status}

    To check status:
      kubectl get configmap edge-controller-client-cm -n ${guardium-data-protection_deployment.edge.edge_namespace} -o yaml
      kubectl get pods -n ${guardium-data-protection_deployment.edge.edge_namespace}
  EOT
}
