# ============================================================================
# IAM test file
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

module "iam" {
  source      = "../../modules/iam"
  environment = "Dev"
}
