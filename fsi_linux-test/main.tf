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

resource "aws_instance" "badvm" {
  ami           = "ami-04453454e335e779c" 
  instance_type = "t2.micro"
  key_name = var.instance_key
  subnet_id = "subnet-09ce085f9d58c82d7"
  security_groups = [aws_security_group.sg.id]

  ebs_block_device {
    device_name           = "/dev/sda1"
    volume_size           = "20"
    volume_type           = "gp2"
    encrypted             = true
    delete_on_termination = true
  }
   tags = {
    Name = "seahk-is-bad-vm-eks-fsi"
    Dept = "Finance"
  }

 }
