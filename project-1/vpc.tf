resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = var.vpc_name
  }
}

# Subnets
resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.region}a"

  tags = {
    Name = "${var.public_subnet_name}-1"
  }
  depends_on = [
    aws_vpc.vpc
  ]
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.region}b"

  tags = {
    Name = "${var.public_subnet_name}-2"
  }
  depends_on = [
    aws_vpc.vpc
  ]
}

resource "aws_subnet" "private-subnet-1" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.region}a"

  tags = {
    Name = "${var.private_subnet_name}-1"
  }
  depends_on = [
    aws_vpc.vpc
  ]
}

resource "aws_subnet" "private-subnet-2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.region}b"

  tags = {
    Name = "${var.private_subnet_name}-2"
  }
  depends_on = [
    aws_vpc.vpc
  ]
}

# Internet GW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.igw_name
  }
  depends_on = [
    aws_vpc.vpc
  ]
}

# route tables
resource "aws_route_table" "public-RT" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = var.route_table_name
  }
  depends_on = [
    aws_internet_gateway.igw
  ]
}

# route associations public
resource "aws_route_table_association" "public-subnet-1-a" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public-RT.id
  depends_on = [
    aws_route_table.public-RT
  ]
}

resource "aws_route_table_association" "public-subnet-2-a" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.public-RT.id
  depends_on = [
    aws_route_table.public-RT
  ]
}
