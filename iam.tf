resource "aws_iam_role" "data_ingest_iam_role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com",
        "Service": "s3.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role" "data_ingest_linux_iam_role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com",
        "Service": "s3.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "data_ingest_linux_iam" {
  role = "${aws_iam_role.data_ingest_linux_iam_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ssm:PutParameter",
                "ssm:GetParameter"
            ],
            "Resource": [
              "arn:aws:ssm:eu-west-2:*:parameter/NATS_sftp_user_private_key",
              "arn:aws:ssm:eu-west-2:*:parameter/NATS_sftp_user_private_key_path",
              "arn:aws:ssm:eu-west-2:*:parameter/NATS_sftp_username",
              "arn:aws:ssm:eu-west-2:*:parameter/NATS_sftp_server_public_ip",
              "arn:aws:ssm:eu-west-2:*:parameter/NATS_sftp_landing_dir",
              "arn:aws:ssm:eu-west-2:*:parameter/ADT_ftp_username",
              "arn:aws:ssm:eu-west-2:*:parameter/ADT_ftp_user_password",
              "arn:aws:ssm:eu-west-2:*:parameter/ADT_ftp_server_public_ip",
              "arn:aws:ssm:eu-west-2:*:parameter/gait_access_key",
              "arn:aws:ssm:eu-west-2:*:parameter/gait_secret_key",
              "arn:aws:ssm:eu-west-2:*:parameter/data_archive_bucket_name",
              "arn:aws:ssm:eu-west-2:*:parameter/maytech_host",
              "arn:aws:ssm:eu-west-2:*:parameter/maytech_user",
              "arn:aws:ssm:eu-west-2:*:parameter/ga_bucket_name",
              "arn:aws:ssm:eu-west-2:*:parameter/maytech_preprod_ssh_private_key",
              "arn:aws:ssm:eu-west-2:*:parameter/ssh_public_key_ssm_wherescape",
              "arn:aws:ssm:eu-west-2:*:parameter/maytech_oag_landing_dir",
              "arn:aws:ssm:eu-west-2:*:parameter/mvt_schema_ssm_password"
            ]
        },
        {
              "Effect": "Allow",
              "Action": ["s3:ListBucket"],
              "Resource": "${var.archive_bucket}"
            },
            {
              "Effect": "Allow",
              "Action": [
                "s3:PutObject"
              ],
              "Resource": "${var.archive_bucket}/*"
            },
            {
              "Effect": "Allow",
              "Action": [
                "kms:Encrypt",
                "kms:Decrypt",
                "kms:ReEncrypt*",
                "kms:GenerateDataKey*",
                "kms:DescribeKey"
                ],
                "Resource": "${var.apps_buckets_kms_key}"
              }
    ]
}
EOF
}

resource "aws_iam_role_policy" "data_ingest_landing_bucket_policy" {
  role = "${aws_iam_role.data_ingest_iam_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": "${aws_s3_bucket.data_landing_bucket.arn}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListObject",
        "s3:DeleteObject"
      ],
      "Resource": "${aws_s3_bucket.data_landing_bucket.arn}/*"
    },
    {
      "Effect": "Allow",
      "Action": "kms:Decrypt",
      "Resource": "${aws_kms_key.data_landing_bucket_key.arn}"
    },
    {
        "Effect": "Allow",
        "Action": [
            "s3:ListBucket"
        ],
        "Resource": "${data.aws_ssm_parameter.data-landing-s3.value}"
    },
    {
        "Effect": "Allow",
        "Action": [
            "s3:GetObject",
            "s3:ListObject",
            "s3:DeleteObject"
        ],
        "Resource": "${data.aws_ssm_parameter.data-landing-s3.value}/*"
    },
    {
        "Effect": "Allow",
        "Action": "kms:Decrypt",
        "Resource": "${data.aws_ssm_parameter.data-landing-kms.value}"
    },
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": "${var.archive_bucket}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": "${var.archive_bucket}/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
        ],
        "Resource": "${var.apps_buckets_kms_key}"
      }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "data_ingest_landing_bucket" {
  role = "${aws_iam_role.data_ingest_iam_role.name}"
}

resource "aws_iam_instance_profile" "data_ingest_linux" {
  role = "${aws_iam_role.data_ingest_linux_iam_role.name}"
}

resource "aws_iam_user" "data_ingest_landing" {
  name = "data_ingest_landing_user"
}

resource "aws_iam_access_key" "data_ingest_landing" {
  user = "${aws_iam_user.data_ingest_landing.name}"
}

resource "aws_iam_group" "data_ingest_landing" {
  name = "data_ingest_landing"
}

resource "aws_iam_group_policy" "data_ingest_landing" {
  group = "${aws_iam_group.data_ingest_landing.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "s3:ListBucket",
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.data_landing_bucket.arn}"
    },
    {
      "Action": "s3:PutObject",
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.data_landing_bucket.arn}/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
        ],
        "Resource": "${aws_kms_key.data_landing_bucket_key.arn}"
      }
  ]
}
EOF
}

resource "aws_iam_group_membership" "data_ingest_landing_bucket" {
  name = "data_ingest_landing_bucket"

  users = ["${aws_iam_user.data_ingest_landing.name}"]

  group = "${aws_iam_group.data_ingest_landing.name}"
}
