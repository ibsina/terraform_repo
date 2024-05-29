terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
  profile = var.profile_name
}

# Create a VPC
resource "aws_vpc" "app_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "seahk-is-APP2-vpc"
  }
}

/*
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.app_vpc.id

  tags = {
    Name = "sales_vpc_igw"
  }
}
*/

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.app_vpc.id
  cidr_block        = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "finance-public-subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    transit_gateway_id = "tgw-017d8f02a13008cc3"
  }

  tags = {
    Name = "finance-public_rt"
  }
}

resource "aws_route_table_association" "public_rt_asso" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Attachment to TGW
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-finance" {
  subnet_ids                                      = [aws_subnet.public_subnet.id]
  transit_gateway_id                              = "tgw-017d8f02a13008cc3"
  vpc_id                                          = aws_vpc.app_vpc.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name     = "tgw-att-finance"
  }
}

resource "aws_instance" "finance-vm" {
  ami           = "ami-0320bcb56016e2c87" 
  instance_type = "t2.micro"
  key_name = var.instance_key
  subnet_id = aws_subnet.public_subnet.id
  associate_public_ip_address = false
  security_groups = [aws_security_group.sg.id]

  user_data = <<-EOF
  #!/bin/bash
  echo "*** Installing apache2"
  sudo apt update -y
  sudo apt install apache2 -y
  echo "*** Completed Installing apache2"
  EOF
  
  tags = {
    Name = "seahk-is-finance-vm"
    Dept = "Finance"
    Tier = "WEB"
  }
}

resource "aws_instance" "BAD-finance-vm" {
  ami           = "ami-0320bcb56016e2c87" 
  instance_type = "t2.micro"
  key_name = var.instance_key
  subnet_id = aws_subnet.public_subnet.id
  associate_public_ip_address = false
  security_groups = [aws_security_group.sg.id]

  user_data = <<-EOF
  #!/bin/bash
  echo "*** Installing apache2"
  sudo apt update -y
  sudo apt install apache2 -y
  echo "*** Completed Installing apache2"
  EOF
  
  tags = {
    Name = "seahk-is-Bad-finance-vm"
    Dept = "Finance"
    Tier = "WEB"
    secured = "NO"
  }
}