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
default = "10.201.10.0/24"
}
variable "public_subnet_cidr" {
default = "10.201.10.0/28"
}