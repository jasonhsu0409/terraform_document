  # Create a VPC named "jason-vpc"
resource "aws_vpc" "example" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "${var.prefix}example-vpc"
  }
}

# Create Subnet資源
resource "aws_subnet" "private" {
  count = 4
  vpc_id = aws_vpc.example.id
  // cidr_block = "10.0.${count.index + 1}.0/24"
   cidr_block = element([
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24"
  ], count.index)
  availability_zone = element(var.azs, count.index % length(var.azs))
  map_public_ip_on_launch = false
  tags = {
    Name = "example-${count.index + 1}-private"
  }
}

resource "aws_subnet" "public" {
  count = 2
  vpc_id = aws_vpc.example.id
  cidr_block = "10.0.${count.index + 5}.0/24"
  availability_zone = element(var.azs, count.index % length(var.azs))
  map_public_ip_on_launch = true
  tags = {
    Name = "example-${count.index + 1}-public"
  }
}

// IGW設定
resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
  tags = {
    Name = "example-igw"
  }
}
// route table設定
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.example.id
  tags = {
    Name = "public-route-table"
  }
}
// route table設定
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.example.id
  tags = {
    Name = "private-route-table"
  }
}
## route talbe connect
resource "aws_route_table_association" "private" {
  count = 4

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public" {
  count = 2

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
// 連結igw
resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id                = aws_internet_gateway.example.id
}

// EIP
resource "aws_eip" "nat" {
  vpc = true
}
// NAT gateway (1b)

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[1].id
}

// set nat with private
resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

