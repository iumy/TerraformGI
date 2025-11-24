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

provider "aws" {
  region                      = "us-east-1"
  access_key                  = "dummy"
  secret_key                  = "dummy"
  skip_credentials_validation = true
  skip_region_validation      = true
  skip_requesting_account_id  = true
}
module "networking" {
  source = "../../modules/networking"

  #aws_region  = "us-east-1" 
  vpc_cidr    = "10.0.0.0/16"
  environment = "dev"
}