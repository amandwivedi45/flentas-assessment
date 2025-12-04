# ---------------------------------------------------------
# VPC
# ---------------------------------------------------------
resource "aws_vpc" "aman_vpc" {
  cidr_block           = "10.40.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "Aman_Dwivedi_VPC"
  }
}

# ---------------------------------------------------------
# Subnets
# ---------------------------------------------------------
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.aman_vpc.id
  cidr_block              = "10.40.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.all.names[0]
  tags = {
    Name = "Aman_Dwivedi_Public_A"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.aman_vpc.id
  cidr_block              = "10.40.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.all.names[1]
  tags = {
    Name = "Aman_Dwivedi_Public_B"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.aman_vpc.id
  cidr_block        = "10.40.11.0/24"
  availability_zone = data.aws_availability_zones.all.names[0]
  tags = {
    Name = "Aman_Dwivedi_Private_A"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.aman_vpc.id
  cidr_block        = "10.40.12.0/24"
  availability_zone = data.aws_availability_zones.all.names[1]
  tags = {
    Name = "Aman_Dwivedi_Private_B"
  }
}

# ---------------------------------------------------------
# Internet Gateway
# ---------------------------------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.aman_vpc.id
  tags = {
    Name = "Aman_Dwivedi_IGW"
  }
}

# ---------------------------------------------------------
# NAT Gateway
# ---------------------------------------------------------

resource "aws_eip" "nat_eip" {
  vpc = true
  tags = {
    Name = "Aman_Dwivedi_NAT_EIP"
  }
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_a.id
  tags = {
    Name = "Aman_Dwivedi_NATGW"
  }
}

# ---------------------------------------------------------
# Route Tables
# ---------------------------------------------------------

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.aman_vpc.id
  tags = {
    Name = "Aman_Dwivedi_Public_RT"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_a_assoc" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b_assoc" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

# Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.aman_vpc.id
  tags = {
    Name = "Aman_Dwivedi_Private_RT"
  }
}

resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.natgw.id
}

resource "aws_route_table_association" "private_a_assoc" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_b_assoc" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_rt.id
}

# ---------------------------------------------------------
# Availability Zones Data
# ---------------------------------------------------------
data "aws_availability_zones" "all" {}
