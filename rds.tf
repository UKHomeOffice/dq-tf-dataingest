resource "aws_db_subnet_group" "rds" {
  name = "rds_main_group"

  subnet_ids = [
    "${aws_subnet.data_ingest.id}",
    "${aws_subnet.data_ingest_az2.id}",
  ]

  tags {
    Name = "rds-subnet-group-${local.naming_suffix}"
  }
}

resource "aws_subnet" "data_ingest_az2" {
  vpc_id                  = "${var.appsvpc_id}"
  cidr_block              = "${var.data_ingest_rds_cidr_block}"
  map_public_ip_on_launch = false
  availability_zone       = "${var.az2}"

  tags {
    Name = "az2-subnet-${local.naming_suffix}"
  }
}

resource "aws_route_table_association" "data_ingest_rt_rds" {
  subnet_id      = "${aws_subnet.data_ingest_az2.id}"
  route_table_id = "${var.route_table_id}"
}

resource "random_string" "password" {
  length  = 16
  special = false
}

resource "random_string" "username" {
  length  = 8
  special = false
}

resource "aws_security_group" "di_db" {
  vpc_id = "${var.appsvpc_id}"

  tags {
    Name = "sg-db-${local.naming_suffix}"
  }

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"

    cidr_blocks = [
      "${var.opssubnet_cidr_block}",
      "${var.data_pipe_apps_cidr_block}",
      "${var.data_ingest_cidr_block}",
      "${var.peering_cidr_block}",
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

resource "aws_db_instance" "postgres" {
  identifier              = "rds-postgres-${local.naming_suffix}"
  allocated_storage       = 100
  storage_type            = "gp2"
  engine                  = "postgres"
  engine_version          = "9.6.11"
  instance_class          = "db.m4.large"
  username                = "${random_string.username.result}"
  password                = "${random_string.password.result}"
  backup_window           = "00:00-01:00"
  maintenance_window      = "mon:01:30-mon:02:30"
  backup_retention_period = 14
  storage_encrypted       = true
  multi_az                = true
  skip_final_snapshot     = true

  db_subnet_group_name   = "${aws_db_subnet_group.rds.id}"
  vpc_security_group_ids = ["${aws_security_group.di_db.id}"]

  lifecycle {
    prevent_destroy = true
  }

  tags {
    Name = "rds-postgres-${local.naming_suffix}"
  }
}
