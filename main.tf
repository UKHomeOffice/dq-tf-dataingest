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

resource "aws_instance" "di_web" {
  key_name                    = "${var.key_name}"
  ami                         = "${data.aws_ami.di_web.id}"
  instance_type               = "t2.medium"
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
      $_ -replace 's3-bucket', "${aws_s3_bucket.data_landing_bucket.id}" `
         -replace 's3-path', 'dq-data-ingest-win' `
         -replace 'destination-path', 'E:\dq\s4_file_ingest\in'
      } | Set-Content $destination_file
  </powershell>
EOF

  tags = {
    Name = "ec2-win-${local.naming_suffix}"
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

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "${var.data_pipe_apps_cidr_block}",
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

resource "aws_security_group" "di_web_linux" {
  vpc_id = "${var.appsvpc_id}"

  tags {
    Name = "sg-web-linux-${local.naming_suffix}"
  }

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "${var.data_pipe_apps_cidr_block}",
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

resource "aws_instance" "di_web_linux" {
  key_name                    = "${var.key_name_linux}"
  ami                         = "${data.aws_ami.di_web_linux.id}"
  iam_instance_profile        = "${aws_iam_instance_profile.data_ingest_landing_bucket.id}"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["${aws_security_group.di_web_linux.id}"]
  associate_public_ip_address = false
  subnet_id                   = "${aws_subnet.data_ingest.id}"
  private_ip                  = "${var.dp_web_linux_private_ip}"

  tags = {
    Name = "linux-instance-${local.naming_suffix}"
  }
}
