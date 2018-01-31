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
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "data_ingest_elb" {
  role = "${aws_iam_role.data_ingest_iam_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:Describe*",
        "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
        "elasticloadbalancing:RegisterTargets"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "data_ingest_landing_bucket" {
  role = "${aws_iam_role.data_ingest_iam_role.arn}"
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
