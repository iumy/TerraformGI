# Terraform Kubernetes Project 

This project involves the creationg of a EKS cluster using Terraform in two availabilit zones.
The aim is to apply best practices throughout

Steps:

1. Repository
2. Recommended .gitignore from Terraform Style Guide
3. Design Decisions:
    - Single or multiple stacks: One stack
        - small and shared lifecyle, 1 developer
        - relatively fast execution, small state file
        - single group of resources, one environment (dev/test)
        - production might use multiple stacks splitting networking, EKS and applications
    - Modules structure (as per Terraform standard module structure):
        - Principles: separation of concerns, Reusability, DRY, Blast Radius reduction, Ownership, Separate testing
        - root module
        - networking module
        - security module
        - eks cluster
        - eks nodes
    - Architecture:
        - Internet Gateway
        - Public Subnets
        - NAT Gateways
        - ALB 
        - Private Subnets
        - EKS Control plane
        - EKS Worker Nodes
        - 2 Availability Zone


        


