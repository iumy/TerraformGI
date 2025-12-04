<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>EKS Assignment - ${owner_name}</title>
</head>
<body>
    <div class="container">
        <h1>EKS Infrastructure Assignment</h1>
        
        <div>
            <span class="eks-badge">EKS Cluster</span>
            <span class="k8s-badge">Kubernetes</span>
        </div>

        <div>Pod Running Successfully!</div>

        <div>
            <div class="info-item">
                <div class="label">Environment</div>
                <div class="value">${environment}</div>
            </div>
            <div class="info-item">
                <div class="label">Cluster Name</div>
                <div class="value">${cluster_name}</div>
            </div>
        </div>

        <h2> Architecture Components</h2>
        <div">
            <div>
                <strong>VPC:</strong> 10.0.0.0/16 across 2 Availability Zones
            </div>
            <div>
                <strong>Public Subnets:</strong> NAT Gateways (10.0.1.0/24, 10.0.2.0/24)
            </div>
            <div>
                <strong>Private Subnets:</strong> EKS Worker Nodes (10.0.10.0/24, 10.0.20.0/24)
            </div>
            <div>
                <strong>NAT Gateway:</strong> One per AZ for high availability
            </div>
            <div>
                <strong>EKS Cluster:</strong> Managed Kubernetes control plane
            </div>
            <div>
                <strong>Worker Nodes:</strong> Running in private subnets
            </div>
            <div>
                <strong>Load Balancer:</strong> AWS Network Load Balancer
            </div>
            <div>
                <strong>Container:</strong> nginx:1.25-alpine
            </div>
        </div>

        <h2>Kubernetes Details</h2>
        <div>
            <div>
                <div>Namespace</div>
                <div><code>webapp</code></div>
            </div>
            <div>
                <div>Service Type</div>
                <div><code>LoadBalancer</code></div>
            </div>
        </div>
    </div>
</body>
</html>