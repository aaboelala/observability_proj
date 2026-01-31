resource "aws_vpc" "main" {
  region               = var.region
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name                                        = "${var.vpc_name}-eks"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }

}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.vpc_private_subnets, count.index)
  availability_zone = element(var.vpc_azs, count.index)
  count             = length(var.vpc_private_subnets)
  lifecycle {
    create_before_destroy = false
  }


  tags = {
    Name                                        = "${var.vpc_name}-eks-private-${count.index}"
    "kubernetes.io/cluster/${var.cluster_name}" = "owened"
    "kubernetes.io/role/internal-elb"           = 1
  }
  depends_on = [aws_vpc.main]
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.vpc_public_subnets, count.index)
  availability_zone       = element(var.vpc_azs, count.index)
  count                   = length(var.vpc_public_subnets)
  map_public_ip_on_launch = true
  lifecycle {
    create_before_destroy = false
  }

  tags = {
    Name                                        = "${var.vpc_name}-eks-public-${count.index}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = 1
  }
  depends_on = [aws_vpc.main]

}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name                                        = "${var.vpc_name}-eks-igw"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
  depends_on = [aws_vpc.main]
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name                                        = "${var.vpc_name}-eks-public-rt"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
  depends_on = [aws_internet_gateway.igw]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  count          = length(var.vpc_public_subnets)
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
  depends_on     = [aws_route_table.public]
}

resource "aws_eip" "nat" {
  count  = length(var.vpc_public_subnets)
  domain = "vpc"

  tags = {
    Name = "${var.vpc_name}-eks-nat-eip-${count.index}"

    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.vpc_public_subnets)
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public.*.id, count.index)
  depends_on    = [aws_vpc.main, aws_eip.nat, aws_subnet.public]

  tags = {
    Name = "${var.cluster_name}-eks-nat-${count.index}"
  }

}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  count  = length(var.vpc_private_subnets)

  tags = {
    Name = "${var.vpc_name}-eks-private-rt"
  }
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = element(aws_nat_gateway.nat.*.id, count.index)
  }
  depends_on = [aws_nat_gateway.nat]

}
resource "aws_route_table_association" "private" {
  count          = length(var.vpc_private_subnets)
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, count.index)
  depends_on     = [aws_route_table.private]
}


