variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "node_group_name" {
  description = "Name of the EKS node group"
  type        = string
}

variable "node_role_arn" {
  description = "ARN of the IAM role for nodes"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for nodes (PRIVATE SUBNETS)"
  type        = list(string)
  
  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least 2 subnets required for high availability across AZs"
  }
}

variable "instance_types" {
  description = "List of instance types for nodes"
  type        = list(string)
  default     = ["t3.small"]
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 4
}

variable "disk_size" {
  description = "Disk size in GB for nodes"
  type        = number
  default     = 20
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "owner_name" {
  description = "Name of infrastructure owner"
  type        = string
}
