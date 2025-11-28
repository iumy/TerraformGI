# ============================================================================
# ROOT MODULE 
# ============================================================================

# ============================================================================
# NETWORKING OUTPUTS
# ============================================================================

output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs (NAT Gateways)"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs (EKS nodes)"
  value       = module.networking.private_subnet_ids
}

output "nat_gateway_public_ips" {
  description = "Public IPs of NAT Gateways"
  value       = module.networking.nat_gateway_public_ips
}

# ============================================================================
# EKS CLUSTER OUTPUTS
# ============================================================================

output "cluster_name" {
  description = "Name of the EKS cluster"
  value       = module.eks_cluster.cluster_name
}

output "cluster_endpoint" {
  description = "Endpoint for EKS Kubernetes API"
  value       = module.eks_cluster.cluster_endpoint
}

output "cluster_version" {
  description = "Kubernetes version of the cluster"
  value       = module.eks_cluster.cluster_version
}

output "cluster_arn" {
  description = "ARN of the EKS cluster"
  value       = module.eks_cluster.cluster_arn
}

# ============================================================================
# EKS NODES OUTPUTS
# ============================================================================

output "node_group_id" {
  description = "ID of the EKS node group"
  value       = module.eks_nodes.node_group_id
}

output "node_group_status" {
  description = "Status of the EKS node group"
  value       = module.eks_nodes.node_group_status
}

# ============================================================================
# APPLICATION OUTPUTS
# ============================================================================

# output "application_url" {
#  description = "URL to access the application (may take 5-10 minutes to provision)"
#  value       = "http://${module.kubernetes_app.load_balancer_hostname}"
#}

# output "load_balancer_hostname" {
#  description = "Load balancer hostname"
# value       = module.kubernetes_app.load_balancer_hostname
#}

# ============================================================================
# KUBECTL CONFIGURATION
# ============================================================================

output "configure_kubectl" {
  description = "Command to configure kubectl to access the cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks_cluster.cluster_name}"
}

# ============================================================================
# DEPLOYMENT INFORMATION
# ============================================================================

output "deployment_info" {
  description = "Complete deployment information"
  value = {
    cluster_name     = module.eks_cluster.cluster_name
    cluster_endpoint = module.eks_cluster.cluster_endpoint
    region           = var.aws_region
    environment      = var.environment
    node_count       = "${var.min_capacity}-${var.max_capacity} nodes"
    # application_url  = "http://${module.kubernetes_app.load_balancer_hostname}"
    owner            = var.owner_name
  }
}
