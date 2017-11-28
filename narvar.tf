provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

resource "aws_vpc" "narvar_vpc" {
  cidr_block = "${var.aws_vpc_block}"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.narvar_vpc.id}"
}

resource "aws_route" "internet_access" {
  route_table_id         = "${aws_vpc.narvar_vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.gw.id}"
}

resource "aws_security_group" "allow_http_https_ssh" {
  name        = "allow_http_https_ssh"
  description = "Allow port tcp/80, tcp/443 and port tcp/22"
  vpc_id      = "${aws_vpc.narvar_vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4300
    to_port     = 4300
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_subnet" "narvar_subnet" {
  vpc_id = "${aws_vpc.narvar_vpc.id}"
  cidr_block = "${var.aws_subnet}"
  map_public_ip_on_launch = true
}

resource "aws_key_pair" "auth" {
  key_name = "default"
  public_key = "${file(var.pub_key_path)}"
}

resource "aws_instance" "test" {
  ami           = "${var.aws_centos_ami}"
  instance_type = "${var.aws_instance_type}"
  vpc_security_group_ids = ["${aws_security_group.allow_http_https_ssh.id}"]
  subnet_id = "${aws_subnet.narvar_subnet.id}"
  key_name = "${aws_key_pair.auth.id}"
  depends_on = ["aws_internet_gateway.gw"]

  tags {
    Name = "test"
    sshUser = "${var.ssh_user}"
  }
}

