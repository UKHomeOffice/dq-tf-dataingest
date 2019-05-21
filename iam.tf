resource "aws_iam_user" "data_ingest_landing" {
  name = "data_ingest_landing_user"
}

resource "aws_iam_access_key" "data_ingest_landing_v2" {
  user = "${aws_iam_user.data_ingest_landing.name}"
}

resource "aws_iam_group" "data_ingest_landing" {
  name = "data_ingest_landing"
}

resource "aws_iam_group_membership" "data_ingest_landing_bucket" {
  name = "data_ingest_landing_bucket"

  users = ["${aws_iam_user.data_ingest_landing.name}"]

  group = "${aws_iam_group.data_ingest_landing.name}"
}

resource "aws_iam_group_policy" "data_ingest_landing" {
  group = "${aws_iam_group.data_ingest_landing.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "s3:HeadBucket",
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.data_landing_bucket.arn}/*"
    },
    {
      "Action": "s3:ListBucket",
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.data_landing_bucket.arn}/*"
    },
    {
      "Action": "s3:GetObject",
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.data_landing_bucket.arn}/*"
    },
    {
      "Action": "s3:PutObject",
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.data_landing_bucket.arn}/*"
    },
    {
      "Action": "s3:DeleteObject",
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

resource "aws_iam_user" "dq_dacc_data_ingest_landing_bucket" {
  name = "dq_dacc_data_ingest_landing_bucket_user"
}

resource "aws_iam_group" "dq_dacc_data_ingest_landing_bucket" {
  name = "dq_dacc_data_ingest_landing_bucket"
}

resource "aws_iam_group_membership" "dq_dacc_data_ingest_landing_bucket" {
  name = "dq_dacc_data_ingest_landing_bucket"

  users = ["${aws_iam_user.dq_dacc_data_ingest_landing_bucket.name}"]

  group = "${aws_iam_group.dq_dacc_data_ingest_landing_bucket.name}"
}

resource "aws_iam_access_key" "dq_dacc_data_ingest_landing_bucket_v2" {
  user = "${aws_iam_user.dq_dacc_data_ingest_landing_bucket.name}"
}

resource "aws_iam_group_policy" "dq_dacc_data_ingest_landing" {
  group = "${aws_iam_group.dq_dacc_data_ingest_landing_bucket.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "s3:HeadBucket",
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.dacc_data_landing_bucket.arn}/*"
    },
    {
      "Action": "s3:ListBucket",
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.dacc_data_landing_bucket.arn}"
    },
    {
      "Action": "s3:GetObject",
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.dacc_data_landing_bucket.arn}/*"
    },
    {
      "Action": "s3:ListObject",
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.dacc_data_landing_bucket.arn}/*"
    },
    {
      "Action": "s3:PutObject",
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.dacc_data_landing_bucket.arn}/*"
    },
    {
      "Action": "s3:DeleteObject",
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.dacc_data_landing_bucket.arn}/*"
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
        "Resource": "${aws_kms_key.dacc_data_landing_bucket_key.arn}"
      }
  ]
}
EOF
}

resource "aws_iam_role" "mds_rds_iam_role" {
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "mds_rds_iam_profile" {
  role = "${aws_iam_role.mds_rds_iam_role.name}"
}

resource "aws_iam_role_policy" "mds_rds_iam_policy" {
  role = "${aws_iam_role.mds_rds_iam_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": "${var.archive_bucket}"
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListObject",
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
