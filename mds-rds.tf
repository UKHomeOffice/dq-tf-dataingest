resource "aws_db_subnet_group" "mds_rds" {
  name = "mds_rds_main_group"

  subnet_ids = [
    "${aws_subnet.data_ingest.id}",
    "${aws_subnet.data_ingest_az2.id}",
  ]

  tags {
    Name = "mds-rds-subnet-group-${local.naming_suffix}"
  }
}

resource "aws_security_group" "mds_db" {
  vpc_id = "${var.appsvpc_id}"

  tags {
    Name = "sg-mds-db-${local.naming_suffix}"
  }

  ingress {
    from_port = 1433
    to_port   = 1433
    protocol  = "tcp"

    cidr_blocks = [
      "${var.opssubnet_cidr_block}",
      "${var.data_ingest_cidr_block}",
      "${var.peering_cidr_block}",
      "${var.dq_lambda_subnet_cidr}",
      "${var.dq_lambda_subnet_cidr_az2}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "mds_postgres" {
  vpc_id = "${var.appsvpc_id}"

  tags {
    Name = "sg-mds-db-${local.naming_suffix}"
  }

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"

    cidr_blocks = [
      "${var.opssubnet_cidr_block}",
      "${var.data_ingest_cidr_block}",
      "${var.peering_cidr_block}",
      "${var.dq_lambda_subnet_cidr}",
      "${var.dq_lambda_subnet_cidr_az2}",
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "random_string" "mds_username" {
  length  = 8
  number  = false
  special = false
}

resource "random_string" "mds_password" {
  length  = 16
  special = false
}

resource "aws_ssm_parameter" "mds_username" {
  name  = "mds_username"
  type  = "SecureString"
  value = "${random_string.mds_username.result}"
}

resource "aws_ssm_parameter" "mds_password" {
  name  = "mds_password"
  type  = "SecureString"
  value = "${random_string.mds_password.result}"
}

resource "aws_db_instance" "mds_mssql_2012" {
  identifier              = "mds-rds-mssql2012-${local.naming_suffix}"
  allocated_storage       = 200
  storage_type            = "gp2"
  engine                  = "sqlserver-se"
  engine_version          = "11.00.6594.0.v1"
  license_model           = "license-included"
  instance_class          = "db.m4.large"
  username                = "${random_string.mds_username.result}"
  password                = "${random_string.mds_password.result}"
  backup_window           = "00:00-01:00"
  maintenance_window      = "mon:01:30-mon:02:30"
  backup_retention_period = 14
  storage_encrypted       = true
  multi_az                = false
  skip_final_snapshot     = true

  monitoring_interval  = "60"
  monitoring_role_arn  = "${var.rds_enhanced_monitoring_role}"

  db_subnet_group_name   = "${aws_db_subnet_group.mds_rds.id}"
  vpc_security_group_ids = ["${aws_security_group.mds_db.id}"]

  lifecycle {
    prevent_destroy = true
  }

  tags {
    Name = "mds-rds-mssql2012-${local.naming_suffix}"
  }
}

resource "aws_db_instance" "mds_postgres" {
  identifier                      = "mds-postgres-${local.naming_suffix}"
  allocated_storage               = 200
  storage_type                    = "gp2"
  engine                          = "postgres"
  engine_version                  = "10.6"
  instance_class                  = "db.m4.large"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  username                        = "${random_string.mds_username.result}"
  password                        = "${random_string.mds_password.result}"
  backup_window                   = "00:00-01:00"
  maintenance_window              = "tue:20:00-tue:22:00"
  backup_retention_period         = 14
  deletion_protection             = true
  storage_encrypted               = true
  multi_az                        = false
  skip_final_snapshot             = true

  monitoring_interval  = "60"
  monitoring_role_arn  = "${var.rds_enhanced_monitoring_role}"

  db_subnet_group_name   = "${aws_db_subnet_group.mds_rds.id}"
  vpc_security_group_ids = ["${aws_security_group.mds_postgres.id}"]

  lifecycle {
    prevent_destroy = true
  }

  tags {
    Name = "mds-rds-postgres-${local.naming_suffix}"
  }
}

module "rds_alarms" {
  source = "github.com/UKHomeOffice/dq-tf-cloudwatch-rds"

  naming_suffix                = "${local.naming_suffix}"
  environment                  = "${var.naming_suffix}"
  pipeline_name                = "MDS"
  db_instance_id               = "${aws_db_instance.mds_mssql_2012.id}"
  swap_alarm                   = "false"
  free_storage_space_threshold = 30000000000                            # 30GB free space
}
