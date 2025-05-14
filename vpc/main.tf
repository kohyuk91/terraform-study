terraform {
  required_providers {
    aws = {
    source = "hashicorp/aws"
    version = "~> 5.0"
    }
  }
}

#######################################################################
# VPC

resource "aws_vpc" "tf-vpc" {
  cidr_block = "10.50.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "tf-vpc"
  }
}


#######################################################################
# Public Subnets

resource "aws_internet_gateway" "tf-vpc-igw" {
  vpc_id = aws_vpc.tf-vpc.id

  tags = {
    Name = "tf-vpc-igw"
  }
}

resource "aws_subnet" "tf-vpc-pub-sub1" {
  vpc_id     = aws_vpc.tf-vpc.id
  cidr_block = "10.50.1.0/24"
  availability_zone = "ap-northeast-2a"
  map_public_ip_on_launch = true
  enable_resource_name_dns_a_record_on_launch = true
  tags = {
    Name = "tf-vpc-pub-sub1"
    "kubernetes.io/cluster/tf-cluster" = "shared"
    "kubernetes.io/role/elb" = "1"
  }

  depends_on = [ aws_internet_gateway.tf-vpc-igw ]
}

resource "aws_subnet" "tf-vpc-pub-sub2" {
  vpc_id     = aws_vpc.tf-vpc.id
  cidr_block = "10.50.10.0/24"
  availability_zone = "ap-northeast-2c"
  map_public_ip_on_launch = true
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name = "tf-vpc-pub-sub2"
    "kubernetes.io/cluster/tf-cluster" = "shared"
    "kubernetes.io/role/elb" = "1"
  }
  
  depends_on = [ aws_internet_gateway.tf-vpc-igw ]
}

resource "aws_route_table" "tf-vpc-pub-rt" {
  vpc_id = aws_vpc.tf-vpc.id

  route {
    cidr_block = "10.50.0.0/16"
    gateway_id = "local"
  }
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-vpc-igw.id
  }

  tags = {
    Name = "tf-vpc-pub-rt"
  }
}

resource "aws_route_table_association" "pub_sub1_rta" {
  subnet_id      = aws_subnet.tf-vpc-pub-sub1.id
  route_table_id = aws_route_table.tf-vpc-pub-rt.id
}

resource "aws_route_table_association" "pub_sub2_rta" {
  subnet_id      = aws_subnet.tf-vpc-pub-sub2.id
  route_table_id = aws_route_table.tf-vpc-pub-rt.id
}


#######################################################################
# Private Subnets

resource "aws_eip" "tf-vpc-ngw-eip" {
  tags = {
    Name = "tf-vpc-ngw-eip"
  }
}

resource "aws_nat_gateway" "tf-vpc-ngw" {
  allocation_id = aws_eip.tf-vpc-ngw-eip.id
  subnet_id     = aws_subnet.tf-vpc-pub-sub1.id

  tags = {
    Name = "tf-vpc-ngw"
  }

  depends_on = [aws_internet_gateway.tf-vpc-igw]
}

resource "aws_subnet" "tf-vpc-prv-sub1" {
  vpc_id     = aws_vpc.tf-vpc.id
  cidr_block = "10.50.2.0/24"
  availability_zone = "ap-northeast-2a"
  enable_resource_name_dns_a_record_on_launch = true
  tags = {
    Name = "tf-vpc-prv-sub1"
    "kubernetes.io/cluster/tf-cluster" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }

  depends_on = [ aws_nat_gateway.tf-vpc-ngw ]
}

resource "aws_subnet" "tf-vpc-prv-sub2" {
  vpc_id     = aws_vpc.tf-vpc.id
  cidr_block = "10.50.20.0/24"
  availability_zone = "ap-northeast-2c"
  enable_resource_name_dns_a_record_on_launch = true

  tags = {
    Name = "tf-vpc-prv-sub2"
    "kubernetes.io/cluster/tf-cluster" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }

  depends_on = [ aws_nat_gateway.tf-vpc-ngw ]
}

resource "aws_route_table" "tf-vpc-prv-rt" {
  vpc_id = aws_vpc.tf-vpc.id

  route {
    cidr_block = "10.50.0.0/16"
    gateway_id = "local"
  }
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.tf-vpc-ngw.id
  }

  tags = {
    Name = "tf-vpc-prv-rt"
  }
}

resource "aws_route_table_association" "prv_sub1_rta" {
  subnet_id      = aws_subnet.tf-vpc-prv-sub1.id
  route_table_id = aws_route_table.tf-vpc-prv-rt.id
}

resource "aws_route_table_association" "prv_sub2_rta" {
  subnet_id      = aws_subnet.tf-vpc-prv-sub2.id
  route_table_id = aws_route_table.tf-vpc-prv-rt.id
}


#######################################################################
# Security Group

resource "aws_security_group" "tf-vpc-pub-sg" {
  vpc_id      = aws_vpc.tf-vpc.id
  name        = "tf-vpc-pub-sg"

  tags = {
    Name = "tf-vpc-pub-sg"
  }
}

resource "aws_security_group_rule" "tf-vpc-http-ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf-vpc-pub-sg.id
}

resource "aws_security_group_rule" "tf-vpc-ssh-ingress" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf-vpc-pub-sg.id
}

resource "aws_security_group_rule" "tf-vpc-all-egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.tf-vpc-pub-sg.id
}

