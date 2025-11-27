# ============================================================================
# ROOT MODULE 
# ============================================================================

variable "aws_region" {
  description = "AWS region for EKS cluster deployment"
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["Dev", "Staging", "Prod"], var.environment)
    error_message = "Environment must be Dev, Staging, or Prod"
  }
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "owner_name" {
  description = "Name of infrastructure owner"
  type        = string
  default     = "Gianluca Iumiento"
}

