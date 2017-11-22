
variable "aws_instance_type" {
  default = "t2.micro"
}

variable "aws_region" {
  default = "us-east-1"
}

# https://wiki.centos.org/Cloud/AWS
variable "aws_centos_ami" {
  default = "ami-ae7bfdb8"
}

variable "aws_vpc_block" {
  default = "10.0.0.0/16"
}

variable "aws_subnet" {
  default = "10.0.0.0/24"
}

variable "pub_key_path" {
  default = "~/.ssh/id_rsa.pub"
}

variable "ssh_user" {
  default = "centos"
}

# Defined in terraform.tfvars (should not be normally commited to github)
variable "aws_access_key" {}
variable "aws_secret_key" {}
