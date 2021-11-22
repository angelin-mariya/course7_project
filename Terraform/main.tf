# 1. create a VPC 
resource "aws_vpc" "prod-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = "true" #gives you an internal domain name
  enable_dns_hostnames = "true" #gives you an internal host name
  enable_classiclink = "false"
  instance_tenancy = "default" 
   
    
  tags = {
    Name = "prod-vpc"
  }
}

# 2. Create Internet Gateway

resource "aws_internet_gateway" "gw" {
    vpc_id = aws_vpc.prod-vpc.id
}

 # 3. Create Custom Route Table

resource "aws_route_table" "prod-route-table" {
    vpc_id = aws_vpc.prod-vpc.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gw.id
    }

    route {
        ipv6_cidr_block = "::/0"
        gateway_id      = aws_internet_gateway.gw.id
    }

    tags = {
       Name = "Prod"
    }
}

 #  4. Create a public Subnet in availability zone us-east-1a

resource "aws_subnet" "public-subnet-1" {
    vpc_id            = aws_vpc.prod-vpc.id
    cidr_block        = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    tags = {
        Name = "prod-subnet"
    }
}
# 5. Create a public Subnet in availability zone us-east-1b
resource "aws_subnet" "public-subnet-2" {
    vpc_id            = aws_vpc.prod-vpc.id
    cidr_block        = "10.0.2.0/24"
    availability_zone = "us-east-1b"
    tags = {
        Name = "prod-subnet"
    }
}

 #  6. Associate subnet with Route Table

resource "aws_route_table_association" "a" {
    subnet_id      = aws_subnet.public-subnet-1.id
    route_table_id = aws_route_table.prod-route-table.id
}

#   . Create Security Group to allow port 22,80,443


# 7. Creating Private Subnets in us-east-1a
resource "aws_subnet" "private-subnet-1" {
  vpc_id =  aws_vpc.prod-vpc.id
  cidr_block = "10.0.3.0/24"          # CIDR block of private subnets
  availability_zone = "us-east-1a"
    tags = {
        Name = "private-subnet"
    }
}
# 7. Creating Private Subnets in us-east-1b
resource "aws_subnet" "private-subnet-2" {
  vpc_id =  aws_vpc.prod-vpc.id
  cidr_block = "10.0.4.0/24"          # CIDR block of private subnets
  availability_zone = "us-east-1b"
    tags = {
        Name = "private-subnet2"
    }
}
# 8. Route table for Private Subnet's

resource "aws_eip" "nateIP" {
  vpc   = true
}
# 9. Creating the NAT Gateway using subnet_id and allocation_id
resource "aws_nat_gateway" "NATgw" {
  allocation_id = aws_eip.nateIP.id
  subnet_id = aws_subnet.public-subnet-1.id
  tags = {
    Name = "gw NAT"
  }

  depends_on = [aws_internet_gateway.gw]
}
# 10. Creating RT for Private Subnet
resource "aws_route_table" "PrivateRT" {    
  vpc_id = aws_vpc.prod-vpc.id
  route {
  cidr_block = "0.0.0.0/0"             # Traffic from Private Subnet reaches Internet via NAT Gateway
  nat_gateway_id = aws_nat_gateway.NATgw.id
  }
}
# 11. Route table Association with Private Subnet's
resource "aws_route_table_association" "PrivateRTassociation" {
  subnet_id = aws_subnet.private-subnet-1.id
  route_table_id = aws_route_table.PrivateRT.id
}
resource "aws_route_table_association" "PrivateRTassociation2" {
  subnet_id = aws_subnet.private-subnet-2.id
  route_table_id = aws_route_table.PrivateRT.id
}
