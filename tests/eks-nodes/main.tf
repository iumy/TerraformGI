# ============================================================================
# EKS nodes test file
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
  region = "us-east-1"
  default_tags {
    tags = {
      Environment = "Dev"
      Service     = "EKS_Cluster"
    }
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}
module "networking" {
  source      = "../../modules/networking"
  environment = "Dev"
  #aws_region  = "us-east-1" 
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]   # NAT Gateways
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"] # EKS Nodes
  availability_zones   = slice(data.aws_availability_zones.available.names, 0, 2)
}
module "security" {
  source = "../../modules/security"
  #aws_region  = "us-east-1" 
  environment = "Dev"
  vpc_cidr    = "10.0.0.0/16"
  vpc_id      = module.networking.vpc_id
}
module "iam" {
  source       = "../../modules/iam"
  environment  = "Dev"
  cluster_name = "eks-cluster"
}
module "eks_cluster" {
  source                    = "../../modules/eks-cluster"
  environment               = "Dev"
  cluster_name              = "GI-EKS_Cluster"
  cluster_security_group_id = module.security.cluster_sg_id
  cluster_role_arn          = module.iam.cluster_role_arn
  subnet_ids                = module.networking.private_subnet_ids
}


module "eks_nodes" {
  source          = "../../modules/eks-nodes"
  cluster_name    = module.eks_cluster.cluster_name
  node_group_name = "GI-EKS_Cluster-node-group"
  node_role_arn   = module.iam.node_role_arn
  subnet_ids      = module.networking.private_subnet_ids

  instance_types = ["t3.small"]
  desired_size   = 2
  min_size       = 2
  max_size       = 4
  # Disk configuration
  disk_size   = 20
  environment = "Dev"
  owner_name  = "Gianluca Iumiento"
  depends_on  = [module.eks_cluster]
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_cluster.cluster_name
}

provider "kubernetes" {
  host                   = module.eks_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

