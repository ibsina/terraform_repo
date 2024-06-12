variable "region" {
default = "ap-southeast-1"
}
variable "instance_type" {
default = "t2.micro"
}
variable "profile_name" {
default = "default"
}
variable "instance_key" {
default = "fgt_sg"
}
variable "vpc_cidr" {
default = "10.202.0.0/16"
}
variable "public_subnet_cidr" {
default = "10.202.0.0/24"
}
variable "security_group_name" {
  type = string
  default = "s4hana_security_group"
}
variable "ec2_name" {
  type    = string
  default = "s4hana-vm"
}