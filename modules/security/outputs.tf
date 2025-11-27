output "cluster_sg_id" {
  description = "Security group ID for EKS cluster"
  value       = aws_security_group.cluster.id
}

output "nodes_sg_id" {
  description = "Security group ID for EKS worker nodes"
  value       = aws_security_group.nodes.id
}

output "alb_sg_id" {
  description = "Security group ID for Application Load Balancer"
  value       = aws_security_group.alb.id
}