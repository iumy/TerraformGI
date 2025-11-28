# ============================================================================
# ROOT MODULE 
# ============================================================================

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "EKS with Terraform"
      ManagedBy   = "Terraform"
      Environment = var.environment
      Owner       = var.owner_name
      Service     = "EKS_Cluster"
    }
  }
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# ============================================================================
# MODULE: NETWORKING (with NAT Gateways)
# ============================================================================
module "networking" {
  source = "./modules/networking"

  vpc_cidr             = var.vpc_cidr
  environment          = var.environment
  availability_zones   = slice(data.aws_availability_zones.available.names, 0, 2)
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# ============================================================================
# MODULE: SECURITY
# ============================================================================
module "security" {
  source = "./modules/security"

  vpc_id      = module.networking.vpc_id
  environment = var.environment
  vpc_cidr    = var.vpc_cidr
}

# ============================================================================
# MODULE: IAM
# ============================================================================
# Purpose: IAM roles and policies for EKS cluster and node groups
# Justification: Required for EKS cluster creation and node group management
# Best Practice: Separate roles for cluster and nodes with minimal permissions
module "iam" {
  source = "./modules/iam"

  environment  = var.environment
  cluster_name = local.cluster_name
}

# ============================================================================
# MODULE: EKS CLUSTER
# ============================================================================
# Purpose: Create managed EKS cluster control plane

module "eks_cluster" {
  source = "./modules/eks-cluster"

  cluster_name              = local.cluster_name
  cluster_version           = var.cluster_version
  subnet_ids                = module.networking.private_subnet_ids
  cluster_role_arn          = module.iam.cluster_role_arn
  cluster_security_group_id = module.security.cluster_sg_id
  # Best Practice: Enable control plane logging for audit and troubleshooting
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  environment               = var.environment
}

# ============================================================================
# MODULE: EKS NODE GROUP
# ============================================================================
# Purpose: Create managed node group in private subnets
module "eks_nodes" {
  source = "./modules/eks-nodes"

  cluster_name    = module.eks_cluster.cluster_name
  node_group_name = "${local.cluster_name}-node-group"
  node_role_arn   = module.iam.node_role_arn
  subnet_ids      = module.networking.private_subnet_ids
  # Instance configuration
  instance_types = [var.instance_type]
  desired_size   = var.desired_capacity
  min_size       = var.min_capacity
  max_size       = var.max_capacity
  # Disk configuration
  disk_size   = var.node_disk_size
  environment = var.environment
  owner_name  = var.owner_name
  depends_on  = [module.eks_cluster]
}

# ============================================================================
# KUBERNETES PROVIDER CONFIGURATION
# ============================================================================
# Purpose: Configure kubectl access to EKS cluster
data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_cluster.cluster_name
}

provider "kubernetes" {
  host                   = module.eks_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# ============================================================================
# LOCALS - Computed Values
# ============================================================================
locals {
  cluster_name = "${var.environment}-eks-cluster"
  # Common tags applied to all resources
  # Computed from user inputs in terraform.tfvars
  common_tags = {
    Project     = "IaC-Assignment-EKS"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Owner       = var.owner_name
  }
}
