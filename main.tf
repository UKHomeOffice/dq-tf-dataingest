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

resource "aws_route_table_association" "data_ingest_rt_association" {
  subnet_id      = "${aws_subnet.data_ingest.id}"
  route_table_id = "${var.route_table_id}"
}

module "di_connectivity_tester_db" {
  source          = "github.com/ukhomeoffice/connectivity-tester-tf"
  subnet_id       = "${aws_subnet.data_ingest.id}"
  user_data       = "LISTEN_tcp=0.0.0.0:5432"
  security_groups = ["${aws_security_group.di_db.id}"]
  private_ip      = "${var.di_connectivity_tester_db_ip}"

  tags = {
    Name             = "ec2-${var.service}-sql-server-${var.environment}"
    Service          = "${var.service}"
    Environment      = "${var.environment}"
    EnvironmentGroup = "${var.environment_group}"
  }
}

module "di_connectivity_tester_web" {
  source          = "github.com/ukhomeoffice/connectivity-tester-tf"
  subnet_id       = "${aws_subnet.data_ingest.id}"
  user_data       = "LISTEN_tcp=0.0.0.0:135 LISTEN_rdp=0.0.0.0:3389 CHECK_db:${var.di_connectivity_tester_db_ip}:5432"
  security_groups = ["${aws_security_group.di_web.id}"]
  private_ip      = "${var.di_connectivity_tester_web_ip}"

  tags = {
    Name             = "ec2-${var.service}-wherescape-${var.environment}"
    Service          = "${var.service}"
    Environment      = "${var.environment}"
    EnvironmentGroup = "${var.environment_group}"
  }
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
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}

resource "aws_security_group" "di_web" {
  vpc_id = "${var.appsvpc_id}"

  tags {
    Name = "${local.name_prefix}web-sg"
  }

  ingress {
    from_port = 135
    to_port   = 135
    protocol  = "tcp"

    cidr_blocks = [
      "${var.data_pipe_apps_cidr_block}",
    ]
  }

  ingress {
    from_port = 3389
    to_port   = 3389
    protocol  = "tcp"

    cidr_blocks = [
      "${var.opssubnet_cidr_block}",
    ]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }
}
