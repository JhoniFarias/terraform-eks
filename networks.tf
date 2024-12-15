
resource "aws_vpc" "tech_challenge_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_subnet" "tech_challenge_public_subnet_1" {
  vpc_id            = aws_vpc.tech_challenge_vpc.id
  cidr_block        = var.subnet_public_1_cidr_block
  availability_zone = var.subnet_availability_zone_az_1

  tags = {
    Name = "tech_challenge_public_subnet_1"
  }
}

resource "aws_subnet" "tech_challenge_public_subnet_2" {
  vpc_id            = aws_vpc.tech_challenge_vpc.id
  cidr_block        = var.subnet_public_2_cidr_block
  availability_zone = var.subnet_availability_zone_az_2

  tags = {
    Name = "tech_challenge_public_subnet_2"
  }
}

# Private Subnets
resource "aws_subnet" "tech_challenge_private_subnet_1" {
  vpc_id            = aws_vpc.tech_challenge_vpc.id
  cidr_block        = var.subnet_private_1_cidr_block
  availability_zone = var.subnet_availability_zone_az_1

  tags = {
    Name = "tech_challenge_private_subnet_1"
  }
}

resource "aws_subnet" "tech_challenge_private_subnet_2" {
  vpc_id            = aws_vpc.tech_challenge_vpc.id
  cidr_block        = var.subnet_private_2_cidr_block
  availability_zone = var.subnet_availability_zone_az_2

  tags = {
    Name = "tech_challenge_private_subnet_2"
  }
}

resource "aws_internet_gateway" "tech_challenge_app_igw" {
  vpc_id = aws_vpc.tech_challenge_vpc.id

  tags = {
    Name = "tech_challenge_app_igw"
  }
}

resource "aws_route_table" "tech_challenge_app_public_rt" {
  vpc_id = aws_vpc.tech_challenge_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tech_challenge_app_igw.id
  }

  tags = {
    Name = "tech_challenge_app_public_rt"
  }
}

resource "aws_route_table_association" "tech_challenge_app_public_rt_association_1" {
  subnet_id      = aws_subnet.tech_challenge_public_subnet_1.id
  route_table_id = aws_route_table.tech_challenge_app_public_rt.id
}

resource "aws_route_table_association" "tech_challenge_app_public_rt_association_2" {
  subnet_id      = aws_subnet.tech_challenge_public_subnet_2.id
  route_table_id = aws_route_table.tech_challenge_app_public_rt.id
}

resource "aws_route_table" "tech_challenge_app_private_rt" {
  vpc_id = aws_vpc.tech_challenge_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.tech_challenge_app_nat_gw.id
  }

  tags = {
    Name = "tech_challenge_app_private_rt"
  }
}

resource "aws_route_table_association" "tech_challenge_app_private_rt_association_1" {
  subnet_id      = aws_subnet.tech_challenge_private_subnet_1.id
  route_table_id = aws_route_table.tech_challenge_app_private_rt.id
}

resource "aws_route_table_association" "tech_challenge_app_private_rt_association_2" {
  subnet_id      = aws_subnet.tech_challenge_private_subnet_2.id
  route_table_id = aws_route_table.tech_challenge_app_private_rt.id
}

resource "aws_eip" "tech_challenge_app_nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "tech_challenge_app_nat_gw" {
  allocation_id = aws_eip.tech_challenge_app_nat_eip.id
  subnet_id     = aws_subnet.tech_challenge_public_subnet_1.id

  tags = {
    Name = "tech_challenge_app_nat_gw"
  }
}
