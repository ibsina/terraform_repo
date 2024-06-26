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
resource "aws_vpc" "web_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "seahk-is-cbc-web-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.web_vpc.id

  tags = {
    Name = "web_igw"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.web_vpc.id
  cidr_block        = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.web_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    /* gateway_id = aws_internet_gateway.igw.id */
    transit_gateway_id = "tgw-017d8f02a13008cc3"
  }

  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table_association" "public_rt_asso" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}


# Attachment to TGW
resource "aws_ec2_transit_gateway_vpc_attachment" "tgw-att-web-tier" {
  subnet_ids                                      = [aws_subnet.public_subnet.id]
  transit_gateway_id                              = "tgw-017d8f02a13008cc3"
  vpc_id                                          = aws_vpc.web_vpc.id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    Name     = "tgw-att-web-tier"
  }
}


resource "aws_instance" "web" {
  ami           = "ami-0a46ef2b5534a90d6" 
  instance_type = var.instance_type
  key_name = var.instance_key
  subnet_id              = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.sg.id]

  user_data = <<-EOF
  #!/bin/bash
  echo "*** Installing apache2"
  sudo apt update -y
  sudo apt install apache2 -y
  echo "*** Completed Installing apache2"
  EOF

  tags = {
    Name = "Sales"
    Group = "Sales"
  }

  volume_tags = {
    Name = "Sales"
  } 
}
resource "aws_instance" "aws_linux2" {
  ami           = "ami-0e72449bd9c509cf3" 
  instance_type = var.instance_type
  key_name = var.instance_key
  subnet_id              = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.sg.id]
 
  # data disk
  ebs_block_device {
    device_name           = "/dev/xvda"
    volume_size           = "50"
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }
  tags = {
    Name = "Marketing"
    Group = "Marketing"
    Tier = "WEB"
  }

  volume_tags = {
    Name = "Marketing"
  } 
}

