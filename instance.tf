variable "appsvpc_id" {}
variable "opsvpc_cidr_block" {}
variable "appsvpc_cidr_block" {}
variable "data_ingest_cidr_block" {}
variable "az" {}
variable "name_prefix" {}

locals {
  name_prefix = "${var.name_prefix}apps-data-ingest-"
}

resource "aws_subnet" "data_ingest" {
  vpc_id                  = "${var.appsvpc_id}"
  cidr_block              = "${var.data_ingest_cidr_block}"
  map_public_ip_on_launch = false
  availability_zone       = "${var.az}"

  tags {
    Name = "${local.name_prefix}subnet"
  }
}

variable instance_type {
  default = "t2.nano"
}

data "aws_ami" "linux_connectivity_tester" {
  most_recent = true

  filter {
    name = "name"

    values = [
      "connectivity-tester-linux*",
    ]
  }

  owners = [
    "093401982388",
  ]
}

resource "aws_instance" "di_postgres" {
  ami                    = "${data.aws_ami.linux_connectivity_tester.id}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${aws_subnet.data_ingest.id}"
  vpc_security_group_ids = ["${aws_security_group.di_db.id}"]

  tags {
    Name = "${local.name_prefix}postgres"
  }

  user_data = "CHECK_self=127.0.0.1:8080 CHECK_google=google.com:80 CHECK_googletls=google.com:443 LISTEN_tcp=0.0.0.0:5432"
}

resource "aws_instance" "di_web" {
  ami                    = "${data.aws_ami.linux_connectivity_tester.id}"
  instance_type          = "${var.instance_type}"
  subnet_id              = "${aws_subnet.data_ingest.id}"
  vpc_security_group_ids = ["${aws_security_group.di_web.id}"]

  tags {
    Name = "${local.name_prefix}web"
  }

  user_data = "CHECK_self=127.0.0.1:8080 CHECK_google=google.com:80 CHECK_googletls=google.com:443 LISTEN_https=0.0.0.0:443 LISTEN_tcp=0.0.0.0:3389"
}

resource "aws_security_group" "di_db" {
  vpc_id = "${var.appsvpc_id}"

  tags {
    Name = "${local.name_prefix}db-sg"
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${var.opsvpc_cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "di_web" {
  vpc_id = "${var.appsvpc_id}"

  tags {
    Name = "${local.name_prefix}web-sg"
  }

  ingress {
    from_port   = 135
    to_port     = 135
    protocol    = "tcp"
    cidr_blocks = ["${var.appsvpc_cidr_block}"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["${var.opsvpc_cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
