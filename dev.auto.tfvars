# ============================================================================
# EKS Configuration
# ============================================================================

aws_region  = "eu-east-1" 
environment = "Dev"
vpc_cidr             = "10.0.0.0/16"
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]    
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]  

# EKS Cluster Configuration
cluster_version = "1.34"  # Kubernetes version

# EKS Node Configuration
instance_type    = "t3.small"  # Minimum 2GB RAM for EKS
desired_capacity = 2           # Number of worker nodes
min_capacity     = 2           # Minimum for HA
max_capacity     = 4           # Maximum for auto-scaling
node_disk_size   = 20          # GB per node

owner_name     = "GianlucaIumiento"
