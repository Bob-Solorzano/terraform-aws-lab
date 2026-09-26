resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.environment}-${var.vpc_name}-vpc"
    Environment = var.environment
  }
}

##################################
# Public Subnet definition
##################################

resource "aws_subnet" "public" {
  for_each = toset(var.public_subnet_cidrs)

  vpc_id     = aws_vpc.this.id
  cidr_block = each.value

  availability_zone = element(
    var.availability_zones,
    index(var.public_subnet_cidrs, each.value)
  )

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-public-${each.value}"
    Tier = "public"
  }
}

##################################
# Internet gateway definition
##################################

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.environment}-${var.internet_gw_name}-intgw"
  }
}

# Internet gateway Route:
resource "aws_route_table" "public" {

  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.environment}-public-rt"
    Tier = "public"
  }
}

# Public Route table Association
resource "aws_route_table_association" "this" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

##################################
# Nat Gateway definition
##################################
resource "aws_eip" "nat" {

  domain = "vpc"

  tags = {
    Name = "${var.environment}-nat-eip"
  }
}

resource "aws_nat_gateway" "this" {

  allocation_id = aws_eip.nat.id

  subnet_id = values(aws_subnet.public)[0].id

  depends_on = [
      aws_internet_gateway.this
  ]
}

# Private Route table
resource "aws_route_table" "private" {

  vpc_id = aws_vpc.this.id

  route {

    cidr_block = "0.0.0.0/0"

    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "${var.environment}-private-rt"
    Tier = "private"
  }

}

resource "aws_route_table_association" "private" {

  for_each = aws_subnet.private

  subnet_id = each.value.id

  route_table_id = aws_route_table.private.id
}


##################################
# Private Subnet definition
##################################

resource "aws_subnet" "private" {
  for_each = toset(var.private_subnet_cidrs)

  vpc_id     = aws_vpc.this.id
  cidr_block = each.value

  availability_zone = element(
    var.availability_zones,
    index(var.private_subnet_cidrs, each.value)
  )

  tags = {
    Name = "${var.environment}-private-${each.value}"
    Tier = "private"
  }
}