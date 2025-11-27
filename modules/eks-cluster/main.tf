# ============================================================================
# EKS CLUSTER MODULE 
# ============================================================================
# Purpose: Create AWS EKS cluster control plane
 
# ============================================================================
# EKS CLUSTER
# ============================================================================
# Purpose: Managed Kubernetes control plane
# - Cluster in private subnets for enhanced security
# - Public endpoint should be disabled for production (enable for dev/testing)
# - Control plane logging enabled for audit and troubleshooting
# - Latest stable Kubernetes version for security patches
# 
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = var.cluster_role_arn
  version  = var.cluster_version

  vpc_config {
    # Subnets for cluster ENIs (control plane network interfaces)
    # https://docs.aws.amazon.com/eks/latest/best-practices/subnets.html
    # Best Practice: Include both public and private subnets
    # - Private: Where control plane ENIs are created
    # - Public: Required if enabling public endpoint access
    subnet_ids = var.subnet_ids

    # Endpoint access configuration
    # Best Practice for production: endpoint_private_access = true, public = false
    # Enable public for easier kubectl access
    endpoint_private_access = true
    endpoint_public_access  = true

    # Security group for cluster control plane
    security_group_ids = [var.cluster_security_group_id]
  }

  # Enable control plane logging
  # Best Practice: Enable all log types for complete audit trail
  # Logs go to CloudWatch Logs (additional costs)
  # reviewed: https://docs.aws.amazon.com/pdfs/eks/latest/best-practices/eks-bpg.pdf
  enabled_cluster_log_types = var.enabled_cluster_log_types

    tags = {
    Name        = var.cluster_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }

  # Best Practice: Ensure IAM role exists before creating cluster
  # https://registry.terraform.io/providers/hashicorp/aws/4.7.0/docs/resources/eks_cluster
  depends_on = [
    var.cluster_role_arn
  ]
}








