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
         -replace 's3-path', 's4' `
         -replace 'destination-path', 'E:\dq\nrt\s4_file_ingest\FTP_landingzone\done'
      } | Set-Content $destination_file

  $original_archive_file = 'C:\scripts\data_transfer_archive.bat'
  $destination_archive_file = 'C:\scripts\data_transfer_archive_config.bat'

  (Get-Content $original_archive_file) | Foreach-Object {
      $_ -replace 's3-bucket', "${var.archive_bucket_name}" `
         -replace 's3-path', 's4/parsed' `
         -replace 'source-path', 'E:\dq\nrt\s4_file_ingest\FTP_landingzone\done'
      } | Set-Content $destination_archive_file

  $original_raw_archive_file = 'C:\scripts\data_transfer_raw_archive.bat'
  $destination_raw_archive_file = 'C:\scripts\data_transfer_raw_archive_config.bat'

  (Get-Content $original_raw_archive_file) | Foreach-Object {
      $_ -replace 's3-bucket', "${var.archive_bucket_name}" `
         -replace 's3-path', 's4/raw' `
         -replace 'source-path', 'E:\dq\nrt\s4_file_ingest\raw_inprocess\done'
      } | Set-Content $destination_raw_archive_file

  $original_ga_file = 'C:\scripts\data_transfer_ga.bat'
  $destination_ga_file = 'C:\scripts\data_transfer_ga_config.bat'

  (Get-Content $original_ga_file) | Foreach-Object {
      $_ -replace 's3-bucket', "${data.aws_ssm_parameter.ga_bucket.value}" `
         -replace 's3-path', 's4' `
         -replace 'source-path', 'E:\dq\nrt\s4_file_ingest\FTP_landingzone\done'
      } | Set-Content $destination_ga_file
  </powershell>
EOF

  lifecycle {
    prevent_destroy = true

    ignore_changes = [
      "user_data",
      "ami_name",
    ]
  }

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
  instance_type               = "t2.medium"
  vpc_security_group_ids      = ["${aws_security_group.di_web_linux.id}"]
  associate_public_ip_address = false
  subnet_id                   = "${aws_subnet.data_ingest.id}"
  private_ip                  = "${var.dp_web_linux_private_ip}"

  user_data = <<EOF
#!/bin/bash

if [ ! -f /bin/aws ]; then
    curl https://bootstrap.pypa.io/get-pip.py | python
    pip install awscli

sudo -u wherescape mkdir -p ~wherescape/.ssh/
sudo -u wherescape "aws --region eu-west-2 ssm get-parameter --name mock_ftp_sftp_server_SFTPuser_private_key --query 'Parameter.Value' --output text --with-decryption | base64 -d > ~wherescape/.ssh/id_rsa"
chmod -R 600 ~wherescape/.ssh/
chown -R wherescape:SSM /NATS/log

echo "export SSH_REMOTE_USER=`aws --region eu-west-2 ssm get-parameter --name mock_ftp_sftp_server_sftp_username --query 'Parameter.Value' --output text --with-decryption`
export SSH_REMOTE_HOST=`aws --region eu-west-2 ssm get-parameter --name mock_ftp_sftp_server_public_ip --query 'Parameter.Value' --output text --with-decryption`
export SSH_LANDING_DIR=`aws --region eu-west-2 ssm get-parameter --name mock_ftp_sftp_server_landing_dir --query 'Parameter.Value' --output text --with-decryption`
export username=`aws --region eu-west-2 ssm get-parameter --name mock_ftp_sftp_server_ftp_username --query 'Parameter.Value' --output text --with-decryption`
export password=`aws --region eu-west-2 ssm get-parameter --name mock_ftp_sftp_server_ftpuser_password --query 'Parameter.Value' --output text --with-decryption`
export server=`aws --region eu-west-2 ssm get-parameter --name mock_ftp_sftp_server_public_ip --query 'Parameter.Value' --output text --with-decryption`" >> /etc/profile.d/nats_script_envs.sh

EOF

  tags = {
    Name = "linux-instance-${local.naming_suffix}"
  }
}
