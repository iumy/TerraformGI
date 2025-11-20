# ============================================================================
# Networking test file
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
module "networking" {
  source = "../../modules/networking"

  #aws_region  = "us-east-1" 
  vpc_cidr    = "10.0.0.0/16"
}