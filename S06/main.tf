provider "aws" {
  version = "~> 2.67"
  profile = "default"
  region = var.region
}
# Networking configurtion: VPC, subnets, gateways and routing

resource "aws_vpc" "iot_service" {
  cidr_block = "10.0.0.0/20"
  enable_dns_hostnames = true
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public1" {
  vpc_id     = aws_vpc.iot_service.id
  map_public_ip_on_launch = true
  cidr_block = "10.0.0.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "public2" {
  vpc_id     = aws_vpc.iot_service.id
  map_public_ip_on_launch = true
  cidr_block = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
}

resource "aws_subnet" "private1" {
  vpc_id     = aws_vpc.iot_service.id
  cidr_block = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
}

resource "aws_subnet" "private2" {
  vpc_id     = aws_vpc.iot_service.id
  cidr_block = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
}

resource "aws_internet_gateway" "inet_gw" {
  vpc_id = aws_vpc.iot_service.id
}

resource "aws_route_table" "public1" {
  vpc_id = aws_vpc.iot_service.id
}

resource "aws_route_table" "public2" {
  vpc_id = aws_vpc.iot_service.id
}

resource "aws_route" "default1" {
  route_table_id = aws_route_table.public1.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.inet_gw.id 
}

resource "aws_route" "default2" {
  route_table_id = aws_route_table.public2.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.inet_gw.id 
}

resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public1.id
}

resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public2.id
}

# Network security configuration: security groups.

resource "aws_security_group" "jump_stations" {
  name = "jump_stations"
  description = "Allow admin with SSH from any location"
  vpc_id = aws_vpc.iot_service.id
# cidr_blocks should contain IP adressess or subnets allowed to manage the environment.
# this hasn't been done to simplify the management of the environment as I don't have a static IP. 
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_servers" {
  name = "web_servers"
  description = "Allow admin with SSH and web HTTP and HTTPS"
  vpc_id = aws_vpc.iot_service.id
  
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.jump_stations.id]
  }
  ingress {
    description = "Allow WEB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow TLS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow ping"
    protocol = "icmp"
    from_port = 8
    to_port = 0
    security_groups = [aws_security_group.jump_stations.id]    
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "database_servers" {
  name = "database_servers"
  description = "Allow admin with SSH and web HTTP and HTTPS"
  vpc_id = aws_vpc.iot_service.id
  
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.jump_stations.id]
  }
  ingress {
    description = "Allow WEB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    self        = true
    security_groups = [aws_security_group.web_servers.id]
  }
  ingress {
    description = "Allow MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    self        = true
    security_groups = [aws_security_group.web_servers.id]
  }
  ingress {
    description = "Allow ping"
    protocol = "icmp"
    from_port = 8
    to_port = 0
    security_groups = [aws_security_group.jump_stations.id]    
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "web_alb" {
  name = "web_alb"
  description = "Allow web HTTP and HTTPS"
  vpc_id = aws_vpc.iot_service.id
  
  ingress {
    description = "Allow WEB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow TLS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow ping"
    protocol = "icmp"
    from_port = 8
    to_port = 0
    security_groups = [aws_security_group.jump_stations.id]    
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
