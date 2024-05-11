data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "labvpc" {
  cidr_block           = var.VPC_CIDR
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name"                                      = "demolabvpc",
    "kubernetes.io/cluster/${var.cluster-name}" = "shared"
  }
}
resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnets_cidr)
  cidr_block              = element(var.public_subnets_cidr, count.index)
  map_public_ip_on_launch = false
  depends_on              = [aws_vpc.labvpc]
  vpc_id                  = aws_vpc.labvpc.id
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    "Name" = "publicsubnet${count.index}"
  }

}
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.labvpc.id
  count                   = length(var.private_subnets_cidr)
  cidr_block              = element(var.private_subnets_cidr, count.index)
  map_public_ip_on_launch = false
  depends_on              = [aws_vpc.labvpc]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    "Name" = "privatesubnet${count.index}"
  }
}
resource "aws_internet_gateway" "labig" {
  depends_on = [aws_vpc.labvpc]
  vpc_id     = aws_vpc.labvpc.id
  tags = {
    "Name" = "LAB IG"
  }
}
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.labvpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.labig.id
  }
  tags = {
    "Name" = "eks-public-route"
  }
}
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)
  depends_on    = [aws_internet_gateway.labig]
  tags = {
    Name = "nat"
  }
}
resource "aws_route_table" "private" {
  vpc_id     = aws_vpc.labvpc.id
  depends_on = [aws_nat_gateway.nat]
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }
  tags = { "Name" = "eks-private-route" }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private.id
}
resource "aws_eip" "nat_eip" {
  depends_on = [aws_internet_gateway.labig]
}
