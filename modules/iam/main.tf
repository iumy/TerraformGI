# ============================================================================
# IAM MODULE 
# ============================================================================
# Purpose: Create IAM roles and policies for EKS cluster and worker nodes
# 
# ============================================================================
# EKS CLUSTER ROLE
# ============================================================================
# Purpose: Allow EKS service to manage cluster resources
# taken from https://docs.aws.amazon.com/eks/latest/userguide/cluster-iam-role.html#create-service-role
resource "aws_iam_role" "cluster" {
  name = "${var.cluster_name}-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${var.environment}-${var.cluster_name}-cluster-role"
  }
}

# Attach AWS-managed policy for EKS cluster
resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# ============================================================================
# EKS NODE ROLE
# ============================================================================
# Purpose: Allow worker nodes to interact with AWS services and EKS cluster
# Required policies:
# - AmazonEKSWorkerNodePolicy: Node management
# - AmazonEC2ContainerRegistryPullOnly: Pull images from ECR
# - AmazonEKS_CNI_Policy: VPC CNI plugin networking
# taken from https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html#:~:text=The%20Amazon%20EKS%20node%20kubelet,provided%20by%20the%20AmazonEC2ContainerRegistryPullOnly%20policy.
resource "aws_iam_role" "node" {
  name = "${var.cluster_name}-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  tags = {
    Name = "${var.environment}-${var.cluster_name}-node-role"
  }
}

# Worker Node Policy
resource "aws_iam_role_policy_attachment" "node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

# ECR Pull-Only Policy
# Nodes need to pull container images from Amazon ECR
resource "aws_iam_role_policy_attachment" "node_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = aws_iam_role.node.name
}

# CNI Policy
# VPC CNI plugin requires this to manage ENIs and IP addresses
# Best Practice: Attach to node role for simplicity (alternative: separate IRSA)
resource "aws_iam_role_policy_attachment" "node_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}
