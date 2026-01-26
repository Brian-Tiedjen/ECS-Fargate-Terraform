#Define the VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

data "aws_region" "current" {}

locals {
  private_subnet_cidrs = [for subnet in values(var.private_subnets) : subnet.cidr]
  interface_endpoints = toset([
    "ecr.api",
    "ecr.dkr",
    "logs",
    "sts",
  ])
}

#Deploy the private subnets
resource "aws_subnet" "private_subnets" {
  for_each          = var.private_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az

  tags = {
    Name        = each.key
    Environment = var.environment
  }
}

#Deploy the public subnets
resource "aws_subnet" "public_subnets" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
  tags = {
    Name        = each.key
    Environment = var.environment
  }
}

#Create Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name        = "${var.environment}_public_route_table"
    Environment = var.environment
  }
}

#Create Private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id     = aws_vpc.vpc.id
  depends_on = [aws_nat_gateway.nat_gateway]
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name        = "${var.environment}_private_route_table"
    Environment = var.environment
  }
}

#Create Public Route Table Associations
resource "aws_route_table_association" "public" {
  depends_on     = [aws_subnet.public_subnets]
  route_table_id = aws_route_table.public_route_table.id
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
}

#Create Private Route Table Associations
resource "aws_route_table_association" "private" {
  depends_on     = [aws_subnet.private_subnets]
  route_table_id = aws_route_table.private_route_table.id
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
}

#Create Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.environment}_internet_gateway"
    Environment = var.environment
  }
}

#Create EIP for NAT Gateway
resource "aws_eip" "nat_gateway_eip" {
  depends_on = [aws_internet_gateway.internet_gateway]
  tags = {
    Name        = "${var.environment}_nat_gateway_eip"
    Environment = var.environment
  }
}

#Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnets[sort(keys(aws_subnet.public_subnets))[0]].id

  tags = {
    Name        = "${var.environment}_nat_gateway"
    Environment = var.environment
  }
}

#Create VPC Interface Endpoint Security Group
resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.environment}-vpc-endpoints-sg"
  description = "Security group for VPC interface endpoints"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow HTTPS from private subnets"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = local.private_subnet_cidrs
  }

  egress = []

  tags = {
    Name        = "${var.environment}-vpc-endpoints-sg"
    Environment = var.environment
  }
}

#Create VPC Interface Endpoints
resource "aws_vpc_endpoint" "interface" {
  for_each            = local.interface_endpoints
  vpc_id              = aws_vpc.vpc.id
  vpc_endpoint_type   = "Interface"
  service_name        = "com.amazonaws.${data.aws_region.current.id}.${each.value}"
  subnet_ids          = [for subnet in values(aws_subnet.private_subnets) : subnet.id]
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.vpc_endpoints.id]

  tags = {
    Name        = "${var.environment}-${replace(each.value, ".", "-")}-vpce"
    Environment = var.environment
  }
}

#Create S3 Gateway Endpoint (for ECR layers)
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc.id
  vpc_endpoint_type = "Gateway"
  service_name      = "com.amazonaws.${data.aws_region.current.id}.s3"
  route_table_ids   = [aws_route_table.private_route_table.id]

  tags = {
    Name        = "${var.environment}-s3-vpce"
    Environment = var.environment
  }
}

resource "aws_default_security_group" "default" {
  vpc_id                 = aws_vpc.vpc.id
  revoke_rules_on_delete = true
  ingress                = []
  egress                 = []

  tags = {
    Name        = "${var.environment}-default-sg"
    Environment = var.environment
  }
}
