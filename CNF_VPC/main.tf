provider "aws" {
  region = "ap-southeast-1"  # Change to your desired region
}

resource "aws_vpc" "main" {
  cidr_block = "10.127.0.0/16"
  tags = {
    Name = "Central-inspection-CNF-vpc"
  }
}

resource "aws_subnet" "subnet_tgw" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index)
  availability_zone = element(["ap-southeast-1a", "ap-southeast-1b"], count.index)
  tags = {
    Name = "subnet-tgw-${element(["a", "b"], count.index)}"
  }
}

resource "aws_subnet" "subnet_gwlbe" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 4, count.index + 2)
  availability_zone = element(["ap-southeast-1a", "ap-southeast-1b"], count.index)
  tags = {
    Name = "subnet-gwlbe-${element(["a", "b"], count.index)}"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tgw_attachment" {
  subnet_ids         = aws_subnet.subnet_tgw[*].id
  transit_gateway_id = "tgw-017d8f02a13008cc3"
  vpc_id             = aws_vpc.main.id
  appliance_mode_support = "enable"
  dns_support            = "enable"
  ipv6_support           = "disable"
  transit_gateway_default_route_table_association = true
  transit_gateway_default_route_table_propagation = true



  tags = {
    Name = "TGW Attachment"
  }
}

resource "aws_ec2_transit_gateway_route_table_association" "tgw_rtb_assoc" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.tgw_attachment.id
  transit_gateway_route_table_id = "tgw-rtb-03b73e7ca6b16fc1b"
}