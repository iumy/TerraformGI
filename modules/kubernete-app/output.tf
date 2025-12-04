output "namespace" {
  description = "Kubernetes namespace name"
  value       = kubernetes_namespace.app.metadata[0].name
}

output "deployment_name" {
  description = "Kubernetes deployment name"
  value       = kubernetes_deployment.webapp.metadata[0].name
}

output "service_name" {
  description = "Kubernetes service name"
  value       = kubernetes_service.webapp.metadata[0].name
}

output "load_balancer_hostname" {
  description = "Load balancer hostname (may take a few minutes to provision)"
  value       = try(kubernetes_service.webapp.status[0].load_balancer[0].ingress[0].hostname, "pending")
}

output "load_balancer_ip" {
  description = "Load balancer IP address (if available)"
  value       = try(kubernetes_service.webapp.status[0].load_balancer[0].ingress[0].ip, "pending")
}