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

module "eks-cluster" {
  source                    = "../../modules/eks-cluster"
  environment               = "Dev"
  cluster_name              = "GI-EKS_Cluster"
  cluster_security_group_id = module.security.cluster_sg_id
  cluster_role_arn          = module.iam.cluster_role_arn
  subnet_ids                = module.networking.private_subnet_ids
 }