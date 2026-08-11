# data source : fetch available AWS regions

data "aws_availability_zones" "available" {
  state = "available"  
}

# VPC module

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-vpc"
  })
}

# internet gateway module

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge (var.common_tags, {
    Name = "${var.project_name}-${var.environment}-igw"
  })
}

#public subnets module

resource "aws_subnet" "public" {
  count = var.az_count

  vpc_id = aws_vpc.main.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

    tags = merge(var.common_tags, {
      Name = "${var.project_name}-${var.environment}-public-subnet-${count.index + 1}"
      type = "public"
    })
}

#private subnets module

resource "aws_subnet" "private" {
  count = var.az_count
  vpc_id = aws_vpc.main.id
    cidr_block = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 10)
    availability_zone = data.aws_availability_zones.available.names[count.index]

    tags = merge(var.common_tags, {
      Name = "${var.project_name}-${var.environment}-private-subnet-${count.index + 1}"
      type = "private"
    })
}

#elastic IP for NAT gateway

resource "aws_eip" "nat" {
  count = var.az_count
  domain = "vpc"

  depends_on = [ aws_internet_gateway.main ]
  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-nat-eip-${count.index + 1}"
  })
}

#NAT gateway module

resource "aws_nat_gateway" "main" {
  count = var.az_count

  allocation_id = aws_eip.nat[count.index].id
  subnet_id = aws_subnet.public[count.index].id

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-${var.environment}-nat-gateway-${count.index + 1}"
  })
  
  depends_on = [ aws_internet_gateway.main ]  
}

#public route table module

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id

    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.main.id
    }
    tags = merge(var.common_tags, {
      Name = "${var.project_name}-${var.environment}-public-rt"
    })
}

#public route table association module

resource "aws_route_table_association" "public" {
  count = var.az_count

  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id  
}

#private route table module

resource "aws_route_table" "private" {
    count = var.az_count
    vpc_id = aws_vpc.main.id

    route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.main[count.index].id
    }
    tags = merge(var.common_tags, {
      Name = "${var.project_name}-${var.environment}-private-rt"
    })
}

#private route table association module

resource "aws_route_table_association" "private" {
  count = var.az_count

  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
