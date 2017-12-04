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
