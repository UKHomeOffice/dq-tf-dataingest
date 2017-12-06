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

module "di_connectivity_tester_db" {
  source          = "github.com/ukhomeoffice/connectivity-tester-tf"
  user_data       = "CHECK_self=127.0.0.1:80 CHECK_google=google.com:80 CHECK_googletls=google.com:443 LISTEN_tcp=0.0.0.0:5432 GROUP_web:${var.di_connectivity_tester_web_ip}:135"
  subnet_id       = "${aws_subnet.data_ingest.id}"
  security_groups = ["${aws_security_group.di_db.id}"]
  private_ip      = "${var.di_connectivity_tester_db_ip}"
}

module "di_connectivity_tester_web" {
  source          = "github.com/ukhomeoffice/connectivity-tester-tf"
  user_data       = "CHECK_self=127.0.0.1:80 CHECK_google=google.com:80 CHECK_googletls=google.com:443 LISTEN_tcp=0.0.0.0:135 LISTEN_rdp=0.0.0.0:3389 GROUP_db:${var.di_connectivity_tester_db_ip}:5432"
  subnet_id       = "${aws_subnet.data_ingest.id}"
  security_groups = ["${aws_security_group.di_web.id}"]
  private_ip      = "${var.di_connectivity_tester_web_ip}"
}

resource "aws_security_group" "di_db" {
  vpc_id = "${var.appsvpc_id}"

  tags {
    Name = "${local.name_prefix}db-sg"
  }

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"

    cidr_blocks = [
      "${var.opssubnet_cidr_block}",
      "${var.data_pipe_apps_cidr_block}",
      "${var.data_ingest_cidr_block}",
    ]
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
    cidr_blocks = ["${var.data_pipe_apps_cidr_block}"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["${var.opssubnet_cidr_block}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
