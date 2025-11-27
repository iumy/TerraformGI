# ============================================================================
# EKS cluster test file
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
module "eks-cluster" {
  source                    = "../../modules/eks-cluster"
  environment               = "Dev"
  cluster_name              = "GI-EKS_Cluster"
  cluster_security_group_id = module.security.cluster_sg_id
  cluster_role_arn          = module.iam.cluster_role_arn
  subnet_ids                = module.networking.private_subnet_ids
}
