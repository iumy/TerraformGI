# ============================================================================
# SECURITY MODULE 
# ============================================================================

# ============================================================================
# CLUSTER SECURITY GROUP
# ============================================================================
# Purpose: Control plane security group
# EKS automatically creates and manages cluster security group
# This is an additional security group for custom rules if needed

resource "aws_security_group" "cluster" {
  name_prefix = "${var.environment}-eks-cluster-sg-"
  description = "Security group for EKS cluster control plane"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.environment}-eks-cluster-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "cluster_egress_to_nodes" {
  description              = "Allow cluster to communicate with worker nodes"
  type                     = "egress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nodes.id
  security_group_id        = aws_security_group.cluster.id
}

resource "aws_security_group_rule" "cluster_egress_to_nodes_https" {
  description              = "Allow cluster to communicate with nodes on 443"
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nodes.id
  security_group_id        = aws_security_group.cluster.id
}

# ============================================================================
# NODE SECURITY GROUP
# ============================================================================
# Purpose: Security group for EKS worker nodes
# - Allow nodes to communicate with each other
# - Allow nodes to communicate with cluster control plane
# - Allow inbound from cluster control plane
resource "aws_security_group" "nodes" {
  name_prefix = "${var.environment}-eks-nodes-sg-"
  description = "Security group for EKS worker nodes"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.environment}-eks-nodes-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Allow nodes to communicate with each other on all ports
resource "aws_security_group_rule" "nodes_internal" {
  description              = "Allow nodes to communicate with each other"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "-1"
  source_security_group_id = aws_security_group.nodes.id
  security_group_id        = aws_security_group.nodes.id
}

# Allow nodes to receive traffic from cluster control plane
resource "aws_security_group_rule" "nodes_from_cluster" {
  description              = "Allow worker nodes to receive communication from cluster control plane"
  type                     = "ingress"
  from_port                = 1025
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.cluster.id
  security_group_id        = aws_security_group.nodes.id
}

# Allow nodes to receive HTTPS traffic from cluster
resource "aws_security_group_rule" "nodes_from_cluster_https" {
  description              = "Allow pods to communicate with cluster API Server"
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.cluster.id
  security_group_id        = aws_security_group.nodes.id
}

# Allow nodes outbound internet access (via NAT Gateway)
resource "aws_security_group_rule" "nodes_egress_internet" {
  description       = "Allow nodes outbound internet access"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nodes.id
}

# ============================================================================
# LOAD BALANCER SECURITY GROUP
# ============================================================================
# Purpose: Security group for Application Load Balancer (if exposing services)
# 
# This is for exposing Kubernetes services via ALB Ingress Controller
resource "aws_security_group" "alb" {
  name_prefix = "${var.environment}-eks-alb-sg-"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  # Allow HTTP from internet
  ingress {
    description = "Allow HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS from internet (if SSL configured)
  ingress {
    description = "Allow HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound to nodes
  egress {
    description = "Allow outbound to worker nodes"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name = "${var.environment}-eks-alb-sg"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Allow nodes to receive traffic from ALB
resource "aws_security_group_rule" "nodes_from_alb" {
  description              = "Allow worker nodes to receive traffic from ALB"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.nodes.id
}

