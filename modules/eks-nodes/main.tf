# ============================================================================
# EKS NODES MODULE 
# ============================================================================
# Purpose: Create EKS managed node group in PRIVATE SUBNETS
# 
# Architecture
# - Nodes deployed in PRIVATE subnets 
# - Access internet via NAT Gateway

# ============================================================================
# EKS MANAGED NODE GROUP
# ============================================================================
# Purpose: Managed worker nodes that join the EKS cluster
# 
resource "aws_eks_node_group" "main" {
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = var.node_role_arn
  subnet_ids      = var.subnet_ids

  # Scaling configuration
  # Best Practice: Minimum 2 nodes across 2 AZs for high availability
  scaling_config {
    desired_size = var.desired_size # Target number of nodes
    max_size     = var.max_size     # Maximum for auto-scaling
    min_size     = var.min_size     # Minimum for high availability
  }

  # Update configuration
  # Best Practice: Rolling updates to avoid downtime
  update_config {
    max_unavailable = 1 # Only one node unavailable during updates
  }

  instance_types = var.instance_types

  # AMI type
  ami_type      = "AL2_x86_64"
  disk_size     = var.disk_size
  capacity_type = "ON_DEMAND"
  # Justification: Labels enable targeted pod placement
  labels = {
    Environment = var.environment
    NodeGroup   = var.node_group_name
    Owner       = var.owner_name
    Assignment  = "IaC-Project"
  }

  tags = {
    Name        = "${var.node_group_name}-node"
    Environment = var.environment
    Owner       = var.owner_name
    ManagedBy   = "EKS"
    NodeGroup   = var.node_group_name
  }

  # Lifecycle policy
  # Best Practice: Prevent accidental deletion in production
  lifecycle {
    create_before_destroy = true
    # Ignore changes to desired_size if using auto-scaling
    ignore_changes = [scaling_config[0].desired_size]
  }

  # Dependencies
  # Ensure cluster exists before creating node group
  depends_on = [
    var.node_role_arn
  ]
}

