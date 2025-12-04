variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "webapp"
}

variable "app_replicas" {
  description = "Number of pod replicas"
  type        = number
  default     = 2
}

variable "owner_name" {
  description = "Name of infrastructure owner"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}