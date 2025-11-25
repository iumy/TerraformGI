# ============================================================================
# NETWORKING MODULE 
# ============================================================================

# ============================================================================
# VPC
# ============================================================================
resource "aws_vpc" "vpc1" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.environment}-vpc"
  }

}

# ============================================================================
# INTERNET GATEWAY
# ============================================================================
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc1.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

# ============================================================================
# ELASTIC IPS FOR NAT GATEWAYS
# ============================================================================
resource "aws_eip" "nat" {
  count = length(var.availability_zones)

  domain = "vpc"

  tags = {
    Name = "${var.environment}-nat-eip-${count.index + 1}"
  }

  # EIP may require IGW to exist prior to association
  depends_on = [aws_internet_gateway.main]
}

# ============================================================================
# PUBLIC SUBNETS 
# ============================================================================

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-subnet-${count.index + 1}"
  }
}

# ============================================================================
# PRIVATE SUBNETS (for EKS Worker Nodes)
# ============================================================================

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.environment}-private-subnet-${count.index + 1}"
  }
}

# ============================================================================
# NAT GATEWAYS
# ============================================================================

resource "aws_nat_gateway" "main" {
  count = length(var.availability_zones)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.environment}-nat-gateway-${count.index + 1}"
    AZ   = var.availability_zones[count.index]
  }

  depends_on = [aws_internet_gateway.main]
}

# ============================================================================
# ROUTE TABLE - Public
# ============================================================================

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0" # ALL internet traffic
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.environment}-public-rt"
  }
}

# ============================================================================
# ROUTE TABLE ASSOCIATIONS - Public Subnets
# ============================================================================
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ============================================================================
# ROUTE TABLES - Private (one per AZ for NAT Gateway routing)
# ============================================================================

resource "aws_route_table" "private" {
  count = length(var.availability_zones) 

  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-private-rt-${count.index + 1}"
  }
}

# ============================================================================
# ROUTES - Private subnet to NAT Gateway
# ============================================================================

resource "aws_route" "private_nat" {
  count = length(var.availability_zones)

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
}

# ============================================================================
# ROUTE TABLE ASSOCIATIONS - Private Subnets
# ============================================================================
resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[0].id
}