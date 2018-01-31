locals {
  naming_suffix = "dataingest-${var.naming_suffix}"
}

resource "aws_subnet" "data_ingest" {
  vpc_id                  = "${var.appsvpc_id}"
  cidr_block              = "${var.data_ingest_cidr_block}"
  map_public_ip_on_launch = false
  availability_zone       = "${var.az}"

  tags {
    Name = "subnet-${local.naming_suffix}"
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
    Name = "sql-server-${local.naming_suffix}"
  }
}

module "di_connectivity_tester_web" {
  source          = "github.com/ukhomeoffice/connectivity-tester-tf"
  subnet_id       = "${aws_subnet.data_ingest.id}"
  user_data       = "LISTEN_tcp=0.0.0.0:135 LISTEN_rdp=0.0.0.0:3389 CHECK_db=${var.di_connectivity_tester_db_ip}:5432"
  security_groups = ["${aws_security_group.di_web.id}"]
  private_ip      = "${var.di_connectivity_tester_web_ip}"

  tags = {
    Name = "wherescape-test-${local.naming_suffix}"
  }
}

resource "aws_instance" "di_web" {
  key_name                    = "${var.key_name}"
  ami                         = "${data.aws_ami.di_web.id}"
  instance_type               = "t2.micro"
  iam_instance_profile        = "${aws_iam_instance_profile.data_ingest_landing_bucket.id}"
  vpc_security_group_ids      = ["${aws_security_group.di_web.id}"]
  associate_public_ip_address = false
  subnet_id                   = "${aws_subnet.data_ingest.id}"
  private_ip                  = "${var.dp_web_private_ip}"

  user_data = <<EOF
  <powershell>
  $original_file = 'C:\scripts\data_transfer.bat'
  $destination_file = 'C:\scripts\data_transfer_config.bat'

  (Get-Content $original_file) | Foreach-Object {
      $_ -replace 'bucket_name', "${aws_s3_bucket.data_landing_bucket.id}" `
         -replace 'source_path', "${var.bucket_src_path}" `
         -replace 'destination_path', 'C:\tmp\'
      } | Set-Content $destination_file
  </powershell>
EOF

  tags = {
    Name = "wherescape-${local.naming_suffix}"
  }
}

resource "aws_security_group" "di_web" {
  vpc_id = "${var.appsvpc_id}"

  tags {
    Name = "sg-web-${local.naming_suffix}"
  }

  ingress {
    from_port = 135
    to_port   = 135
    protocol  = "tcp"

    cidr_blocks = [
      "${var.data_pipe_apps_cidr_block}",
      "${var.peering_cidr_block}",
    ]
  }

  ingress {
    from_port = 3389
    to_port   = 3389
    protocol  = "tcp"

    cidr_blocks = [
      "${var.opssubnet_cidr_block}",
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
