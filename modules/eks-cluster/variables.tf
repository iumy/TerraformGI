variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version for the cluster"
  type        = string
  default     = "1.28"
}

variable "cluster_role_arn" {
  description = "ARN of the IAM role for the cluster"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the cluster"
  type        = list(string)
}

variable "cluster_security_group_id" {
  description = "Security group ID for the cluster control plane"
  type        = string
}

variable "enabled_cluster_log_types" {
  description = "List of control plane logging types to enable"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_cni_version" {
  description = "VPC CNI addon version"
  type        = string
  default     = ""
}

variable "coredns_version" {
  description = "CoreDNS addon version"
  type        = string
  default     = ""
}

variable "kube_proxy_version" {
  description = "Kube-proxy addon version"
  type        = string
  default     = ""
}